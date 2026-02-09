const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Telegram Credentials
const TELEGRAM_BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN || "8347412984:AAER9EWg3UIP5qW-Saqwp85KvoZzPAfgUIs"; // Fallback for dev only

// Route to handle notification requests
app.post('/notify', async (req, res) => {
    const { title, content, channel_id } = req.body;

    if (!title || !content || !channel_id) {
        return res.status(400).send({ error: "Title, content, and channel_id are required" });
    }

    console.log(`Received new note: ${title} for channel: ${channel_id}`);

    const message = `📝 *New Note Created*\n\n*Title:* ${title}\n*Content:* ${content}`;

    try {
        const telegramRes = await axios.post(
            `https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`,
            {
                chat_id: channel_id,
                text: message,
                parse_mode: "Markdown",
            }
        );
        console.log("Telegram response:", telegramRes.data);
        console.log("Telegram notification sent!");
        res.status(200).send({ success: true, message: "Notification sent" });
    } catch (error) {
        console.error("Error sending to Telegram:", error.response?.data || error.message);
        res.status(500).send({ error: "Failed to send notification" });
    }
});

app.post('/verify-telegram', async (req, res) => {
    const { channel_username } = req.body;

    if (!channel_username) {
        return res.status(400).send({ error: "Channel username required" });
    }

    try {
        const chatRes = await axios.get(
            `https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getChat`,
            { params: { chat_id: channel_username } }
        );

        const channelId = chatRes.data.result.id;
        const channelTitle = chatRes.data.result.title || channel_username;

        // OPTIONAL: send test message
        await axios.post(
            `https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`,
            {
                chat_id: channelId,
                text: "✅ Telegram connected successfully",
            }
        );

        res.send({
            success: true,
            channel_id: channelId.toString(),
            channel_name: channelTitle,
        });

    } catch (err) {
        console.error("Verification error:", err.response?.data || err.message);
        res.status(400).send({
            success: false,
            error: "Bot is not admin or channel not accessible",
        });
    }
});


// Route to handle note sharing
app.get('/share/:noteId', (req, res) => {
    const noteId = req.params.noteId;
    const appScheme = `flutter-note-app://note/${noteId}`;
    const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.example.note_app'; // Replace with actual package name

    const html = `
    <!DOCTYPE html>
    <html>
    <head>
        <title>Shared Note</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body { font-family: sans-serif; text-align: center; padding: 20px; }
            .btn { display: inline-block; padding: 10px 20px; background-color: #6200ea; color: white; text-decoration: none; border-radius: 5px; margin-top: 20px; }
        </style>
    </head>
    <body>
        <h2>Opening Note...</h2>
        <p>If the app doesn't open automatically, click the button below.</p>
        <a href="${appScheme}" class="btn">Open in App</a>
        <p><small>Don't have the app? <a href="${playStoreUrl}">Download it here</a>.</small></p>

    <script>
        // Attempt to open the app scheme immediately
        window.location.href = "${appScheme}";

        // Fallback to Play Store after a short delay
        setTimeout(function() {
            // Check if the user is still on the page (meaning app didn't open)
            // This is a simple heuristic; modern browsers make this tricky.
            // Often just redirecting is the best effort.
            window.location.href = "${playStoreUrl}";
        }, 1500); // 1.5 seconds delay
    </script>
</body>
</html>
    `;

    res.send(html);
});

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
