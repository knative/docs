const cors = require('cors');
const express = require('express');
const {HTTP, CloudEvent} = require('cloudevents');
const {Pool} = require('pg');
const expressWs = require('express-ws');

const app = express();
const port = 8000;


// Middleware to parse JSON bodies
app.use(express.json());
app.use(cors());
expressWs(app);  // Apply WebSocket functionality to Express

// Configure the PostgreSQL connection pool
const pool = new Pool({
    host: 'postgresql.default.svc.cluster.local',
    port: 5432,
    database: 'mydatabase',
    user: 'myuser',
    password: 'mypassword', // no password as per your setup, but included for completeness
});

app.ws('/comments', (ws, req) => {
    console.log('WebSocket connection established on /comments');

    // Function to send all comments to the connected client
    const sendComments = async () => {
        try {
            const {rows} = await pool.query('SELECT * FROM book_reviews;');
            const data = JSON.stringify(rows);
            if (ws.readyState === ws.OPEN) {
                ws.send(data);
            }
        } catch (err) {
            console.error('Error executing query', err.stack);
            if (ws.readyState === ws.OPEN) {
                ws.send(JSON.stringify({error: 'Failed to retrieve comments'}));
            }
        }
    };

    // Optionally, you can trigger this function based on certain conditions
    // Here, we just send data immediately after connection and on an interval
    sendComments();
    const interval = setInterval(sendComments, 10000); // Send comments every 10 seconds

    ws.on('close', () => {
        console.log('WebSocket connection on /comments closed');
        clearInterval(interval);
    });

    ws.on('error', error => {
        console.error('WebSocket error on /comments:', error);
    });
});


app.post('/add', async (req, res) => {
    try {
        const receivedEvent = HTTP.toEvent({headers: req.headers, body: req.body});
        const brokerURI = process.env.K_SINK;

        if (receivedEvent.type === 'new-review-comment') {
            // Forward the event to the broker with the necessary CloudEvent headers
            const response = await fetch(brokerURI, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'ce-specversion': '1.0',
                    'ce-type': 'new-review-comment',
                    'ce-source': 'bookstore-eda',
                    'ce-id': receivedEvent.id,
                },
                body: JSON.stringify(receivedEvent.data),
            });

            if (!response.ok) { // If the response status code is not 2xx, consider it a failure
                console.error('Failed to forward event:', receivedEvent);
                return res.status(500).json({error: 'Failed to forward event'});
            }

            // If forwarding was successful, acknowledge the receipt of the event
            console.log('Event forwarded successfully:', receivedEvent);
            return res.status(200).json({success: true, message: 'Event forwarded successfully'});
        } else {
            // Handle unexpected event types
            console.warn('Unexpected event type:', receivedEvent.type);
            return res.status(400).json({error: 'Unexpected event type'});
        }
    } catch (error) {
        console.error('Error processing request:', error);
        return res.status(500).json({error: 'Internal server error'});
    }
});

// Start the server
app.listen(port, () => {
    console.log(`Server listening at http://localhost:${port}`);
});
