package io.automatiko.examples.registration;

import java.util.ArrayList;
import java.util.List;

import javax.enterprise.context.ApplicationScoped;

import io.automatiko.engine.api.event.EventSource;
import io.quarkus.arc.profile.IfBuildProfile;

@ApplicationScoped
@IfBuildProfile("test")
public class MockEventSource implements EventSource {

    private static List<EventData> events = new ArrayList<EventData>();

    @Override
    public void produce(String type, String source, Object data) {
        System.out.println("Sending event with type " + type + " source " + source + " and data " + data);
        events.add(new EventData(type, source, data));
    }

    public List<EventData> events() {
        List<EventData> copied = new ArrayList<MockEventSource.EventData>(events);
        events.clear();
        return copied;
    }

    class EventData {

        String type;
        String source;
        Object data;

        public EventData(String type, String source, Object data) {
            this.type = type;
            this.source = source;
            this.data = data;
        }

        public String getType() {
            return type;
        }

        public String getSource() {
            return source;
        }

        public Object getData() {
            return data;
        }

    }
}
