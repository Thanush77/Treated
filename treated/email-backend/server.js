const express = require('express');
const nodemailer = require('nodemailer');
const cors = require('cors');
const bodyParser = require('body-parser');
const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Email Configuration
const EMAIL = 'thanushbd07@gmail.com';
const APP_PASSWORD = 'tpabnbmslwtrbkxq';

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: EMAIL,
        pass: APP_PASSWORD,
    },
});

// Database connection
const db = mysql.createPool({
    host: 'localhost', 
    user: 'thanush',
    password: 'thanush',
    database: 'treated',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
});

// Create user table
const createUserTable = `
  CREATE TABLE IF NOT EXISTS user (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )
`;

(async () => {
    try {
        await db.query(createUserTable);
        console.log('User table created or already exists.');
    } catch (err) {
        console.error('Error creating user table:', err);
    }
})();

// Email endpoint
app.post('/send-email', async (req, res) => {
    const { name, email, message } = req.body;

    if (!name || !email || !message) {
        return res.status(400).json({ error: 'All fields are required' });
    }

    const mailOptions = {
        from: EMAIL,
        to: 'thanushdinesh04@gmail.com',
        subject: `Contact Form Message from ${name}`,
        text: `
Name: ${name}
Email: ${email}
Message: ${message}
        `,
    };

    try {
        await transporter.sendMail(mailOptions);
        res.status(200).json({ message: 'Email sent successfully' });
    } catch (error) {
        console.error('Error sending email:', error);
        res.status(500).json({ error: 'Failed to send email' });
    }
});

// User Management endpoints
app.post('/api/addUsers', async (req, res) => {
    const { username, email, password } = req.body;

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const [result] = await db.query(
            'INSERT INTO user (username, email, password) VALUES (?, ?, ?)',
            [username, email, hashedPassword]
        );
        res.send(`User with ID ${result.insertId} added successfully!`);
    } catch (error) {
        console.error('Server error:', error);
        res.status(500).send('Error processing request');
    }
});

app.get('/api/getUsers', async (req, res) => {
    try {
        const [results] = await db.query(
            'SELECT user_id, username, email, time FROM user'
        );
        res.json(results);
    } catch (err) {
        console.error('Database error:', err);
        res.status(500).send('Error retrieving users');
    }
});

// User login endpoint
app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json({ error: 'Username and password are required' });
    }

    try {
        const [results] = await db.query(
            'SELECT * FROM user WHERE username = ?',
            [username]
        );

        if (results.length === 0) {
            return res.status(401).json({ error: 'User not found' });
        }

        const user = results[0];
        const passwordMatch = await bcrypt.compare(password, user.password);

        if (!passwordMatch) {
            return res.status(401).json({ error: 'Invalid password' });
        }

        res.json({
            message: 'Login successful',
            user: {
                id: user.user_id,
                username: user.username,
                email: user.email,
            },
        });
    } catch (err) {
        console.error('Database error:', err);
        res.status(500).send('Error during login');
    }
});

// Start server on 0.0.0.0 to allow external connections
const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
});
