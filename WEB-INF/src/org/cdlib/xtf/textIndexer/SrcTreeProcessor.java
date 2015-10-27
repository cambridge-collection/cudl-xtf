package org.cdlib.xtf.textIndexer;


/**
 * Copyright (c) 2004, Regents of the University of California
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * - Neither the name of the University of California nor the names of its
 *   contributors may be used to endorse or promote products derived from this
 *   software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.StringTokenizer;
import java.util.Vector;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.sax.SAXSource;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.tree.TreeBuilder;
import net.sf.saxon.value.StringValue;

import org.apache.lucene.util.StringUtil;
import org.cdlib.xtf.cache.Dependency;
import org.cdlib.xtf.cache.FileDependency;
import org.cdlib.xtf.servletBase.StylesheetCache;
import org.cdlib.xtf.textEngine.IndexUtil;
import org.cdlib.xtf.util.Attrib;
import org.cdlib.xtf.util.EasyNode;
import org.cdlib.xtf.util.Path;
import org.cdlib.xtf.util.StructuredStore;
import org.cdlib.xtf.util.SubDirFilter;
import org.cdlib.xtf.util.Trace;
import org.cdlib.xtf.util.XMLWriter;
import org.xml.sax.InputSource;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

/**
 * This class is the main processing shell for files in the source text
 * tree. It optimizes Lucene database access by opening the index once at
 * the beginning, processing all the source files in the source tree
 * (including skipping non-source XML files in the tree), and closing the
 * database at the end. <br><br>
 *
 * Internally, this class uses the {@link org.cdlib.xtf.textIndexer.XMLTextProcessor}
 * class to actually split the source files up into chunks and add them to the
 * Lucene index.
 *
 */
public class SrcTreeProcessor 
{
  private IndexerConfig cfgInfo;
  private XMLTextProcessor textProcessor;
  private StylesheetCache stylesheetCache = new StylesheetCache(100, 0, true);
  private Templates docSelector;
  private int nScanned = 0;
  private StringBuffer docBuf = new StringBuffer(1024);
  private StringBuffer dirBuf = new StringBuffer(1024);
  private String docSelPath;
  private File docSelCacheFile;
  private DocSelCache docSelCache = new DocSelCache();

  ////////////////////////////////////////////////////////////////////////////

  /** Default constructor. <br><br>
   *
   *  Instantiates the {@link org.cdlib.xtf.textIndexer.XMLTextProcessor}
   *  used internally to process individual XML source files. <br><br>
   */
  public SrcTreeProcessor() 
  {
    // Instantiate a text processor object to use on each XML file
    // encountered in the file tree.
    //
    textProcessor = new XMLTextProcessor();
  } // SrcTreeProcessor()

  ////////////////////////////////////////////////////////////////////////////

  /** Indexing open function. <br><br>
   *
   *  Calls the {@link org.cdlib.xtf.textIndexer.XMLTextProcessor}
   *  {@link org.cdlib.xtf.textIndexer.XMLTextProcessor#open(String, IndexInfo, boolean, boolean) open()}
   *  method to actually create/open the Lucene index.
   *
   *  @param cfgInfo   The {@link org.cdlib.xtf.textIndexer#IndexerConfig IndexerConfig}
   *                   that indentifies the Lucene index, source text tree, and
   *                   other parameters required to perform indexing. <br><br>
   *
   *  @throws IOException  Any I/O exceptions generated by the
   *                       {@link org.cdlib.xtf.textIndexer.XMLTextProcessor}
   *                       {@link org.cdlib.xtf.textIndexer.XMLTextProcessor#open(String, IndexInfo, boolean, boolean) open()}
   *                       method. <br><br>
   */
  public void open(IndexerConfig cfgInfo)
    throws Exception 
  {
    // Hang on to a reference to the config info.
    this.cfgInfo = cfgInfo;

    // If no XTF home directory specified, assume it is the same
    // directory as the config file.
    //
    if (cfgInfo.xtfHomePath == null) {
      cfgInfo.xtfHomePath = new File(cfgInfo.cfgFilePath).getParentFile()
                            .toString();
    }

    // Make a transformer for the docSelector stylesheet.
    docSelPath = Path.resolveRelOrAbs(cfgInfo.xtfHomePath,
                                      cfgInfo.indexInfo.docSelectorPath);
    docSelector = stylesheetCache.find(docSelPath);

    // Load the previous docSelector cache (if any)
    loadCache(cfgInfo);

    // Open the Lucene index specified by the config info.
    textProcessor.open(cfgInfo.xtfHomePath, cfgInfo.indexInfo, cfgInfo.clean,
        cfgInfo.force);
    cfgInfo.clean = false;
  } // open()

  ////////////////////////////////////////////////////////////////////////////

  /** Indexing close function. <br><br>
   *
   *  Calls the {@link org.cdlib.xtf.textIndexer.XMLTextProcessor}
   *  {@link org.cdlib.xtf.textIndexer.XMLTextProcessor#processQueuedTexts() processQueuedTexts()}
   *  method to flush all the pending Lucene writes to disk. Then it calls the
   *  {@link org.cdlib.xtf.textIndexer.XMLTextProcessor}
   *  {@link org.cdlib.xtf.textIndexer.XMLTextProcessor#close() close()}
   *  method to actually close the Lucene index. <br><br>
   *
   *  @throws IOException  Any I/O exceptions generated by the
   *                       {@link org.cdlib.xtf.textIndexer.XMLTextProcessor}
   *                       {@link org.cdlib.xtf.textIndexer.XMLTextProcessor#close() close()}
   *                       method. <br><br>
   *
   */
  public void close()
    throws IOException 
  {
    // Flush the remaining open documents.    
    textProcessor.processQueuedTexts();

    // Save the doc selector cache. We do this *after* processing the texts,
    // in case something catastrophic happens in there.
    //
    saveCache();

    // Let go of the config info now that we're done with it.
    cfgInfo = null;

    // Close the index database.
    textProcessor.close();
  } // close()

  ////////////////////////////////////////////////////////////////////////////

  String calcIndexPath()
  {
    String indexPath = Path.resolveRelOrAbs(cfgInfo.xtfHomePath,
        cfgInfo.indexInfo.indexPath);
    return Path.normalizePath(indexPath);
  }

  ////////////////////////////////////////////////////////////////////////////

  /** Load the previous docSelector cache.
   *
   *  @param cfgInfo   The {@link org.cdlib.xtf.textIndexer#IndexerConfig IndexerConfig}
   *                   that indentifies the Lucene index, source text tree, and
   *                   other parameters required to perform indexing. <br><br>
   */
  public void loadCache(IndexerConfig cfgInfo) 
  {
    docSelCache.clear();

    // Figure out the path to the cache file
    docSelCacheFile = new File(calcIndexPath() + "docSelect.cache");

    // Calculate all the file dependencies of the docSelector stylesheet.
    Iterator iter = stylesheetCache.getDependencies(docSelPath);
    StringBuffer depBuf = new StringBuffer();
    while (iter.hasNext()) 
    {
      Dependency d = (Dependency)iter.next();
      if (d instanceof FileDependency) {
        depBuf.append(d.toString());
        depBuf.append("\n");
      }
    }
    docSelCache.dependencies = depBuf.toString();

    // If we're making a clean index, delete the old cache file.
    if (cfgInfo.clean) {
      docSelCacheFile.delete();
      return;
    }

    // If the cache file doesn't exist, don't load it.
    if (!docSelCacheFile.canRead())
      return;

    // Read the file.
    String thisDep = docSelCache.dependencies;
    try {
      docSelCache.load(docSelCacheFile);
    }
    catch (IOException e) {
      Trace.warning(
          "Warning: Error loading docSelector cache \"" + docSelCacheFile +
          "\": " + e);
      docSelCache.clear();
      return;
    }
    
    // If the dependencies are different, toss it.
    if (!docSelCache.dependencies.equals(thisDep)) {
      Trace.debug(
        "Note: docSelector stylesheet or sub-sheet " +
        " has changed... throwing away " + "old docSelector cache.");
      docSelCacheFile.delete();
      docSelCache.clear();
      docSelCache.dependencies = thisDep;
      return;
    }
  } // loadCache()

  ////////////////////////////////////////////////////////////////////////////

  /** Save the docSelector cache.
   */
  public void saveCache() 
  {
    try {
      docSelCache.save(docSelCacheFile);
    }
    catch (IOException e) {
      Trace.warning(
        "Warning: Error writing docSelector cache \"" + docSelCacheFile + "\": " + e);
    }
  } // saveCache()

  ////////////////////////////////////////////////////////////////////////////

  /** Process a directory containing source XML files. <br><br>
   *
   * This method iterates through a source directory's contents indexing any
   * valid files it finds, any processing any sub-directories. <br><br>
   *
   * @param curDir        The current directory to be processed. <br>
   * @param subDirFilter  Sub-dirs to scan, or null for all. <br>
   * @param topLevel      true for the top-level directory, false else. <br>     
   *
   *  @throws   Exception  Any exceptions generated internally
   *                       by the <code>File</code> class or the
   *                       {@link org.cdlib.xtf.textIndexer.XMLTextProcessor}
   *                       class. <br><br>
   *
   */

  public void processDir(File curDir, SubDirFilter subDirFilter, boolean topLevel)
    throws Exception 
  {
    // If we're only doing a subset and this directory isn't in it, skip.
    if (subDirFilter != null && !subDirFilter.approve(curDir))
      return;
    
    // We're looking at a directory. Get the list of files it contains.
    String[] fileStrs = curDir.getAbsoluteFile().list();
    if (fileStrs == null) {
      Trace.warning(
        "Warning: error retrieving file list for directory: " + curDir);
      return;
    }

    ArrayList list = new ArrayList(fileStrs.length);
    for (int i = 0; i < fileStrs.length; i++)
      list.add(fileStrs[i]);
    Collections.sort(list);

    // Process all of the non-directory files first. Form a document 
    // representing the directory and all its files.
    //
    docBuf.setLength(0);
    dirBuf.setLength(0);

    String dirPath = Path.normalizePath(curDir.toString());
    docBuf.append("<directory dirPath=\"" + StringUtil.escapeHTMLChars(dirPath) + "\">\n");
    int nFiles = 0;
    for (Iterator i = list.iterator(); i.hasNext();) 
    {
      File subFile = new File(curDir, (String)i.next());
      if (!subFile.getAbsoluteFile().isDirectory()) 
      {
        docBuf.append("  <file fileName=\"");
        docBuf.append(StringUtil.escapeHTMLChars(subFile.getName()));
        docBuf.append("\"/>\n");

        dirBuf.append(StringUtil.escapeHTMLChars(subFile.getName()));
        dirBuf.append(':');
        dirBuf.append(subFile.lastModified());
        dirBuf.append("\n");

        ++nFiles;

        // Print out dots as we process large amounts of files, just so 
        // the user knows something is happening.
        //
        if (((nScanned++) % 200) == 0)
          Trace.more(Trace.info, ".");
      }
    }
    docBuf.append("</directory>\n");

    // Now process the document using the docSelector stylesheet.
    boolean anyProcessed = false;
    boolean runStylesheet;
    String inStr = docBuf.toString();
    String filesAndTimes = dirBuf.toString();
    String dirKey;
    if (topLevel)
      dirKey = cfgInfo.indexInfo.indexName + ":/";
    else
      dirKey = IndexUtil.calcDocKey(new File(cfgInfo.xtfHomePath),
                                    cfgInfo.indexInfo, curDir);
    
    if (nFiles == 0)
      runStylesheet = false;
    else 
    {
      DocSelCache.Entry ent = (DocSelCache.Entry)docSelCache.get(dirKey);
      if (ent == null)
        runStylesheet = true;
      else if (cfgInfo.force || !ent.filesAndTimes.equals(filesAndTimes)) {
        docSelCache.remove(dirKey);
        runStylesheet = true;
      }
      else {
        anyProcessed = ent.anyProcessed;
        runStylesheet = false;
      }
    }

    if (runStylesheet) 
    {
      InputSource docSelectorInput = new InputSource(new StringReader(inStr));

      if (Trace.getOutputLevel() >= Trace.debug) {
        Trace.debug("*** docSelector input ***\n" + inStr);
        Trace.debug("");
      }

      TreeBuilder tree = new TreeBuilder();
      Transformer docSelectorTrans = docSelector.newTransformer();
      
      // Handle pass-through attributes from the config file.
      for (Iterator i = cfgInfo.indexInfo.passThroughAttribs.iterator(); i.hasNext();) {
        Attrib a = (Attrib)i.next();
        if (a.value == null || a.value.length() == 0)
          continue;
        docSelectorTrans.setParameter(a.key, new StringValue(a.value));
      }

      docSelectorTrans.transform(new SAXSource(docSelectorInput), tree);
      NodeInfo result = tree.getCurrentRoot();

      if (Trace.getOutputLevel() >= Trace.debug) {
        Trace.debug("*** docSelector output ***\n" +
                    XMLWriter.toString(result));
        Trace.debug("");
      }

      // Iterate the result, and queue any files to index.
      EasyNode root = new EasyNode(result);
      for (int i = 0; i < root.nChildren(); i++) 
      {
        EasyNode node = root.child(i);
        if (!node.isElement())
          continue;

        String tagName = node.name();

        if (tagName.equalsIgnoreCase("indexFiles")) {
          root = node;
          i = -1;
          continue;
        }

        if (tagName.equalsIgnoreCase("indexFile")) {
          if (processFile(dirPath, node))
            anyProcessed = true;
        }
        else {
          Trace.error(
            "Error: docSelector returned unknown element '" + tagName + "'");
          return;
        }
      } // while

      // Store this in the cache so we don't have to run the stylesheet
      // next time (that is, unless the directory contents or stylesheet
      // are different).
      //
      docSelCache.put(dirKey, new DocSelCache.Entry(filesAndTimes, anyProcessed));
    } // if nFiles > 0

    // In the old mode (scanAllDirs = false), if we found any files to process, 
    // the convention is that subdirectories contain file related to the ones 
    // we processed, and that they shouldn't be processed individually.
    //
    // In the new mode (scanAllDirs = true), we always process subdirs. This
    // seems to be what most people really want and expect.
    //
    if (anyProcessed && !cfgInfo.indexInfo.scanAllDirs)
      return;

    // Recursively try sub-directories.
    for (Iterator i = list.iterator(); i.hasNext();) {
      File subFile = new File(curDir, (String)i.next());
      if (subFile.getAbsoluteFile().isDirectory())
        processDir(subFile, subDirFilter, false);
    }
  } // processDir()

  ////////////////////////////////////////////////////////////////////////////

  /** Process file. <br><br>
   *
   * This method processes a source file, including source text XML files,
   * PDF files, etc. <br><br>
   *
   * @param parentEl       DOM element representing the current file to be
   *                       processed. This may be a source XML file, PDF file,
   *                       etc. <br><br>
   *
   * @return               true if the document was processed, false if it was
   *                       skipped due to skipping rules.<br><br>
   *
   * @throws   Exception   Any exceptions generated internally by the <code>File</code>
   *                       class or the {@link org.cdlib.xtf.textIndexer.XMLTextProcessor}
   *                       class. <br><br>
   *
   */
  public boolean processFile(String dir, EasyNode parentEl)
    throws Exception 
  {
    // Gather all the info from the element's attributes.
    File srcPath = null;
    Vector preFilterVec = new Vector();
    Templates displayStyle = null;
    String fileName = null;
    String format = null;
    boolean removeDoctypeDecl = false;

    for (int i = 0; i < parentEl.nAttrs(); i++) 
    {
      String attrName = parentEl.attrName(i);
      String attrVal = parentEl.attrValue(i);

      // Get the file name and check it.
      if (attrName.equalsIgnoreCase("fileName")) 
      {
        fileName = attrVal; // for extension checking only
        srcPath = new File(Path.normalizeFileName(dir + attrVal));
        if (!srcPath.canRead()) {
          Trace.error("Error: cannot read input document '" + srcPath + "'");
          return false;
        }
      }

      // Is there an input filter(s) specified?
      else if (attrName.equalsIgnoreCase("preFilter")) 
      {
        // Break up a list separated by semicolons or commas.
        StringTokenizer st = new StringTokenizer(attrVal, ";,");
        while (st.hasMoreTokens()) {
          String partialPath = st.nextToken();
          String preFilterPath = Path.resolveRelOrAbs(cfgInfo.xtfHomePath,
                                                      partialPath);
          preFilterVec.add(stylesheetCache.find(preFilterPath));
        } // while
      } // else

      // If there a display stylesheet specified?
      else if (attrName.equalsIgnoreCase("displayStyle")) {
        String displayPath = Path.resolveRelOrAbs(cfgInfo.xtfHomePath, attrVal);
        displayStyle = stylesheetCache.find(displayPath);
      }

      // Is there a format specified?
      else if (attrName.equalsIgnoreCase("type")) 
      {
        format = attrVal;
       // System.out.println("hi json here!!");
        if (format.equalsIgnoreCase("XML"))
          format = "XML";
        else if (format.equalsIgnoreCase("PDF"))
          format = "PDF";
        else if (format.equalsIgnoreCase("HTML"))
          format = "HTML";
        else if (format.equalsIgnoreCase("DOC") || format.equalsIgnoreCase("MSWord"))
          format = "MSWord";
        else if (format.equalsIgnoreCase("Text"))
          format = "Text";
        else if (format.equalsIgnoreCase("MARC"))
          format = "MARC";
        else if (format.equalsIgnoreCase("JSON"))
          format = "JSON";
//          System.out.println("hi json here!!");break;}
        else {
          Trace.error("Error: docSelector returned unknown type: '" + format +
                      "'");
          return false;
        }
      }

      // Is DOCTYPE declaration removal specified?
      else if (attrName.equalsIgnoreCase("removeDoctypeDecl")) 
      {
        if (attrVal.matches("^yes$|^true$"))
          removeDoctypeDecl = true;
        else if (attrVal.matches("^no$|^false$"))
          removeDoctypeDecl = false;
        else {
          Trace.error(
            "Error: docSelector returned invalid value for " + attrName +
            " attribute: " +
            "expected 'true', 'yes', 'false', or 'no', but found '" + attrVal +
            "'");
          return false;
        }
      }

      // Other attributes are in error.
      else {
        Trace.error(
          "Error: docSelector returned unknown attribute: '" + attrName + "'");
        return false;
      }
    } // while

    // Make sure the filename was specified.
    if (srcPath == null) {
      Trace.error("Error: docSelector must return 'fileName' attribute");
      return false;
    }

    // If no format was specified, make a guess.
    if (format == null && fileName != null) 
    {
      String lcFileName = fileName.toLowerCase();
      if (lcFileName.endsWith(".xml"))
        format = "XML";
      else if (lcFileName.endsWith(".pdf"))
        format = "PDF";
      else if (lcFileName.endsWith(".htm") || lcFileName.endsWith(".html"))
        format = "HTML";
      else if (lcFileName.endsWith(".doc"))
        format = "MSWord";
      else if (lcFileName.endsWith(".txt"))
        format = "Text";
      else if (lcFileName.endsWith(".marc") || lcFileName.endsWith(".mrc"))
        format = "MARC";
       else if (lcFileName.endsWith(".json") || lcFileName.endsWith(".json"))
        format = "JSON";
      else {
        Trace.warning(
          "Warning: cannot deduce file type from extension on file '" +
          srcPath);
        return false;
      }
    }

    // We need to refer to the file in a way that isn't dependent on the
    // particular location the index is at right now. So calculate a key
    // that just contains the index name and the part of the path after that
    // index's data directory.
    //
    String key = IndexUtil.calcDocKey(new File(cfgInfo.xtfHomePath),
                                      cfgInfo.indexInfo, srcPath);

    // Calculate a proper system ID for this file.
    String systemId = srcPath.toURL().toString();

    // Figure out where to put the lazy file (if we've been asked to build one)
    StructuredStore lazyStore = null;
    if (cfgInfo.buildLazyFiles) 
    {
      // Figure out where to put the lazy tree file. We don't create
      // the directory just yet, since for non-XML files the store will
      // never be used.
      //
      File lazyFile = IndexUtil.calcLazyPath(new File(cfgInfo.xtfHomePath),
                                             cfgInfo.indexInfo,
                                             srcPath,
                                             false); // false: don't create yet

      // Use a file proxy so that we don't actually open the file handle
      // until (and if) the queued file is actually indexed.
      //
      lazyStore = new StructuredFileProxy(lazyFile);
    }

    // Convert the prefilter(s) to an array.
    Templates[] preFilters = null;
    if (!preFilterVec.isEmpty())
      preFilters = (Templates[])preFilterVec.toArray(
        new Templates[preFilterVec.size()]);

    // Now we have enough info to construct the SrcFile.
    IndexSource srcFile = null;
    if (format.equalsIgnoreCase("XML")) {
      InputSource finalSrc = new InputSource(systemId);
      srcFile = new XMLIndexSource(finalSrc,
                                   srcPath,
                                   key,
                                   preFilters,
                                   displayStyle,
                                   lazyStore);
      if (removeDoctypeDecl)
        ((XMLIndexSource)srcFile).removeDoctypeDecl(true);
    }
    else if (format.equalsIgnoreCase("PDF"))
      srcFile = new PDFIndexSource(srcPath, key, preFilters, displayStyle, null);
    else if (format.equalsIgnoreCase("HTML"))
      srcFile = new HTMLIndexSource(srcPath, key, preFilters, displayStyle, null);
    else if (format.equalsIgnoreCase("MSWord"))
      srcFile = new MSWordIndexSource(srcPath, key, preFilters, displayStyle, null);
    else if (format.equalsIgnoreCase("Text"))
      srcFile = new TextIndexSource(srcPath, key, preFilters, displayStyle, null);
    else if (format.equalsIgnoreCase("JSON"))
      srcFile = new JSONIndexSource(srcPath, key, preFilters, displayStyle, null);
    else if (format.equalsIgnoreCase("MARC"))
      srcFile = new MARCIndexSource(srcPath, key, preFilters, displayStyle);
    else
      throw new RuntimeException("Internal error: code missing support for type");

    // Now queue up the file.
    textProcessor.checkAndQueueText(srcFile);

    // Let the caller know we didn't skip the file.
    return true;
  } // processFile()
  
} // class SrcTreeProcessor
