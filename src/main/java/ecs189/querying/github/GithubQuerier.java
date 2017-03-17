package ecs189.querying.github;

import ecs189.querying.Util;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.net.URL;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Created by Vincent on 10/1/2017.
 */
public class GithubQuerier {

    private static final String BASE_URL = "https://api.github.com/users/";

    public static String eventsAsHTML(String user) throws IOException, ParseException {
        StringBuilder sb = new StringBuilder();
        int count = 1;
        while(true) {
            int pusheventcount = 0;
            List<JSONObject> response = getEvents(user, count);
            if (response == null)
                break;
            count++;
            sb.append("<div>");
            for (int i = 0; i < response.size(); i++) {
                JSONObject event = response.get(i);
                // Get event type
                String type = event.getString("type");
                // Get created_at date, and format it in a more pleasant style
                String creationDate = event.getString("created_at");
                SimpleDateFormat inFormat = new SimpleDateFormat("yyyy-MM-dd'T'hh:mm:ss'Z'");
                SimpleDateFormat outFormat = new SimpleDateFormat("dd MMM, yyyy");
                Date date = inFormat.parse(creationDate);
                String formatted = outFormat.format(date);

                // Add type of event as header
                if (type.equals("PushEvent") && pusheventcount < 10) {
                    pusheventcount++;
                    sb.append("<h3 class=\"type\">");
                    sb.append(type);
                    sb.append("</h3>");
                    // Add formatted date
                    sb.append(" on ");
                    sb.append(formatted);
                    sb.append("<br />");
                    // Add collapsible JSON textbox (don't worry about this for the homework; it's just a nice CSS thing I like)
                    sb.append("<a data-toggle=\"collapse\" href=\"#event-" + i + "\">JSON</a>");
                    sb.append("<div id=event-" + i + " class=\"collapse\" style=\"height: auto;\"> <pre>");
                    sb.append(event.toString());
                    sb.append("</pre> </div>");
                }
            }
            sb.append("</div>");
            if (pusheventcount == 10)
                break;
        }
        return sb.toString();
    }

    private static List<JSONObject> getEvents(String user, int pgnum) throws IOException {
        List<JSONObject> eventList = new ArrayList<JSONObject>();
        String url = BASE_URL + user + "/events?per_page=100&page="+pgnum;
        System.out.println(url);
        JSONObject json = Util.queryAPI(new URL(url));
        System.out.println(json);
        JSONArray events = json.getJSONArray("root");
        if (events.length() == 0)
            return null;
        for (int i = 0; i < events.length() && i < 10; i++) {
            eventList.add(events.getJSONObject(i));
        }
        return eventList;
    }
}