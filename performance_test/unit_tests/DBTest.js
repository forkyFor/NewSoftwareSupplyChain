const fs = require('fs');
const db = require('./db'); // Assicurati che il path del modulo DB sia corretto
const logFile = fs.openSync('./db_test_log.txt', 'a');

const originalLog = console.log;
const originalError = console.error;

console.log = (...args) => {
    fs.writeSync(logFile, `${args.join(' ')}\n`);
    originalLog(...args);
};

console.error = (...args) => {
    fs.writeSync(logFile, `${args.join(' ')}\n`);
    originalError(...args);
};

function testModule(sender) {
    async function testDatabaseOperations() {
        try {
            // Test: Insert new user
            await db.query('INSERT INTO users (blockchain_address, email) VALUES ($1, $2)', [sender, 'test@example.com']);
            console.log('User insertion successful.');

            // Test: Test inserted
            const res = await db.query('SELECT * FROM users WHERE blockchain_address = $1', [sender]);
            if (res.rows.length > 0) {
                console.log('User fetch successful:', JSON.stringify(res.rows[0]));
            } else {
                console.error('User fetch failed: No data found.');
            }

            // Test: remove user
            await db.query('DELETE FROM users WHERE blockchain_address = $1', [sender]);
            console.log('User deletion successful.');
        } catch (error) {
        console.error('Database operation failed:', error);
    }
}

testDatabaseOperations();
}

module.exports = testModule;