
package org.cdlib.xtf.textIndexer;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.transform.Templates;
import org.apache.commons.io.IOUtils;
import org.cdlib.xtf.util.StructuredStore;
import org.apache.commons.io.IOUtils;
import org.json.JSONException;
import org.json.JSONObject;
import org.xml.sax.InputSource;

/**
 *
 * @author rekha
 */
public class JSONIndexSource extends XMLIndexSource {

    public JSONIndexSource(File jsonFile, String key, Templates[] preFilters,
            Templates displayStyle, StructuredStore lazyStore) {
        super(null, jsonFile, key, preFilters, displayStyle, lazyStore);
        this.jsonFile = jsonFile;
    }
    /**
     * Source of JSON data
     */
    private File jsonFile;

    protected InputSource filterInput() throws IOException {

        InputStream is = null;

        is = new FileInputStream(jsonFile);
        //convert to json file object to string
        String jsonTxt = IOUtils.toString(is);
        
        JSONObject json = new JSONObject();
        try {
            //add a root tag 
            json.put("root", (new JSONObject(jsonTxt)));
        } catch (JSONException ex) {
            Logger.getLogger(JSONIndexSource.class.getName()).log(Level.SEVERE, null, ex);
        }
        String jsonXMLStr = null;
        try {
            jsonXMLStr = org.json.XML.toString(json);
            
        } catch (JSONException ex) {
            Logger.getLogger(JSONIndexSource.class.getName()).log(Level.SEVERE, null, ex);
        }

        // And make an InputSource with a proper system ID
        InputSource finalSrc = new InputSource(new StringReader(jsonXMLStr));
        finalSrc.setSystemId(jsonFile.toURL().toString());
        return finalSrc;

    }

}
