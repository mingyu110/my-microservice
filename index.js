const express = require('express');
const app = express();
const port = process.env.PORT || 3000;
const version = process.env.VERSION || '1.0.0';

app.get('/', (req, res) => {
    res.send(`Version: ${version}`);
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
