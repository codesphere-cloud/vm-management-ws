const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const app = express();
const PORT = 3000;

const TARGET_URL = process.env.VM_URL;

const proxyOptions = {
    target: TARGET_URL,
    changeOrigin: true, 
    ws: true,           
    logLevel: 'debug',
    onError: (err, req, res) => {
        console.error('Proxy error:', err);
        res.status(500).send('Proxy error occurred.');
    }
};

app.use(createProxyMiddleware(proxyOptions));

app.listen(PORT, () => {
    console.log(`Express Reverse Proxy listening on port ${PORT}`);
    console.log(`Proxying all traffic to: ${TARGET_URL}`);
});