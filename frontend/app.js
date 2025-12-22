// Check backend health on load
document.addEventListener('DOMContentLoaded', function() {
    checkApiHealth();
});

async function checkApiHealth() {
    try {
        const response = await fetch('/api/health');
        if (response.ok) {
            const data = await response.json();
            document.getElementById('apiStatus').innerHTML = 
                `<span class="status healthy">✓ Healthy</span> - ${data.timestamp}`;
        } else {
            throw new Error('API not healthy');
        }
    } catch (error) {
        document.getElementById('apiStatus').innerHTML = 
            `<span class="status error">✗ Error</span> - Cannot reach backend API`;
        console.error('Health check failed:', error);
    }
}

async function fetchMessage() {
    const messageElement = document.getElementById('message');
    messageElement.innerHTML = 'Fetching...';
    
    try {
        const response = await fetch('/api/message');
        if (response.ok) {
            const data = await response.json();
            messageElement.innerHTML = 
                `<strong>${data.message}</strong><br>
                 <small>Retrieved at: ${new Date(data.timestamp).toLocaleString()}</small>`;
        } else {
            throw new Error('Failed to fetch message');
        }
    } catch (error) {
        messageElement.innerHTML = 
            `<span class="status error">Error: Could not fetch message from database</span>`;
        console.error('Fetch failed:', error);
    }
}
