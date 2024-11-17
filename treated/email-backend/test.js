const axios = require('axios');

const baseURL = 'http://localhost:4010';
const testUser = {
    username: 'testuser',
    email: 'testuser@example.com',
    password: 'password123'
};

async function runTests() {
    try {
        // Test 1: Add User
        console.log('\nTesting Add User...');
        const addUserResponse = await axios.post(`${baseURL}/api/addUsers`, testUser);
        console.log('Add User Response:', addUserResponse.data);

        // Test 2: Login
        console.log('\nTesting Login...');
        const loginResponse = await axios.post(`${baseURL}/api/login`, {
            username: testUser.username,
            password: testUser.password
        });
        console.log('Login Response:', loginResponse.data);

        // Test 3: Get Users
        console.log('\nTesting Get Users...');
        const getUsersResponse = await axios.get(`${baseURL}/api/getUsers`);
        console.log('Get Users Response:', getUsersResponse.data);

        // Test 4: Send Email
        console.log('\nTesting Send Email...');
        const emailResponse = await axios.post(`${baseURL}/send-email`, {
            name: 'Test User',
            email: 'test@example.com',
            message: 'This is a test message'
        });
        console.log('Send Email Response:', emailResponse.data);

    } catch (error) {
        console.error('Test failed:', error.response?.data || error.message);
    }
}

// Run the tests
runTests();