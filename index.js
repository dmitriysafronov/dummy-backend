var express = require("express");
var app = express();

// Ingress
app.enable('trust proxy');

// --- <Logger

const winston = require('winston');
const consoleTransport = new winston.transports.Console();
const myWinstonOptions = {
    transports: [consoleTransport]
};
const logger = new winston.createLogger(myWinstonOptions);

function logRequest(req, res, next) {
    logger.info('ip: ' + req.ip + ', hostname: ' + req.hostname + ', url: ' + req.url);
    next();
}
app.use(logRequest);

function logError(err, req, res, next) {
    logger.error('ip: ' + req.ip + ', hostname: ' + req.hostname + ', url: ' + req.url + ' <-> ' + err);
    next();
}
app.use(logError);

// --- Logger>

app.get("/", (req, res, next) => {
  res.status(200).send('<a href="/api">/api</a>');
  next();
});

app.get("/api", (req, res, next) => {
  res.status(200).send('<a href="/api/users">/api/users</a>');
  next();
});

app.get("/api/users", (req, res, next) => {
  res.json([
    {"id": "1", "title": "One"},
    {"id": "2", "title": "Two"},
    {"id": "3", "title": "Three"},
    {"id": "4", "title": "Four"}
  ]);
  next();
});

app.listen(3000, () => {
 console.log("Server running on port 3000");
});
