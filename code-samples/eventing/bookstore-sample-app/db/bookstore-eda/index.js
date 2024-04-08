const express = require('express');
const { HTTP, CloudEvent } = require('cloudevents');

const app = express();
const port = 8000;


// Middleware to parse JSON bodies
app.use(express.json()); // This line is crucial


app.post('/add', async (req, res) => {
    try {
        const receivedEvent = HTTP.toEvent({ headers: req.headers, body: req.body });
        const brokerURI = process.env.K_SINK;

        if (receivedEvent.type === 'new-comment') {
            // Forward the event to the broker with the necessary CloudEvent headers
            const response = await fetch(brokerURI, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'ce-specversion': '1.0',
                    'ce-type': 'sentiment-analysis-request',
                    'ce-source': 'bookstore-eda',
                    'ce-id': receivedEvent.id,
                },
                body: JSON.stringify(receivedEvent.data),
            });

            if (!response.ok) { // If the response status code is not 2xx, consider it a failure
                console.error('Failed to forward event:', receivedEvent);
                return res.status(500).json({ error: 'Failed to forward event' });
            }

            // If forwarding was successful, acknowledge the receipt of the event
            console.log('Event forwarded successfully:', receivedEvent);
            return res.status(200).json({ success: true, message: 'Event forwarded successfully' });
        } else {
            // Handle unexpected event types
            console.warn('Unexpected event type:', receivedEvent.type);
            return res.status(400).json({ error: 'Unexpected event type' });
        }
    } catch (error) {
        console.error('Error processing request:', error);
        return res.status(500).json({ error: 'Internal server error' });
    }
});

// Start the server
app.listen(port, () => {
    console.log(`Server listening at http://localhost:${port}`);
});
