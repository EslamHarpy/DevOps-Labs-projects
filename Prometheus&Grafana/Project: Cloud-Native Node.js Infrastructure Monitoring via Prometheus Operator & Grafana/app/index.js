const express = require('express');
const client = require('prom-client');

const app = express();
const port = process.env.PORT || 3000;

// Create a Registry to register the metrics
const register = new client.Registry();

// Add a default metrics collection to the registry
client.collectDefaultMetrics({ register });

// Create a custom counter metric for HTTP requests
const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
});
register.registerMetric(httpRequestsTotal);

// Create a custom histogram for request duration
const httpRequestDurationSeconds = new client.Histogram({
  name: 'request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});
register.registerMetric(httpRequestDurationSeconds);

// Middleware to track metrics for every request
app.use((req, res, next) => {
  const start = process.hrtime();

  res.on('finish', () => {
    const diff = process.hrtime(start);
    const durationInSeconds = diff[0] + diff[1] / 1e9;

    if (req.path !== '/metrics') {
      httpRequestsTotal.labels(req.method, req.path, res.statusCode).inc();
      httpRequestDurationSeconds.labels(req.method, req.path, res.statusCode).observe(durationInSeconds);
    }
  });

  next();
});

// 1. Home Route (The Enhanced UI with forced high-contrast colors)
app.get('/', (req, res) => {
  const htmlContent = `
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Eslam Harpy | DevOps Metrics App</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
      body {
        background-color: #0f172a !important;
        color: #ffffff !important;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      }
      .card-custom {
        background-color: #1e293b !important;
        border: 1px solid #334155 !important;
        border-radius: 12px;
      }
      .badge-devops {
        background-color: #3b82f6 !important;
        color: white !important;
        font-size: 0.9rem;
      }
      .badge-tech {
        background-color: #475569 !important;
        color: #ffffff !important;
        margin: 2px;
        padding: 6px 10px;
        display: inline-block;
        border-radius: 4px;
      }
      .btn-trigger {
        background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%) !important;
        border: none !important;
        color: white !important;
        transition: transform 0.2s;
      }
      .btn-trigger:hover {
        transform: scale(1.05);
        background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%) !important;
      }
      .metrics-link {
        color: #38bdf8 !important;
        text-decoration: none;
      }
      .metrics-link:hover {
        text-decoration: underline;
      }
   
      .force-white {
        color: #ffffff !important;
      }
      .force-light-gray {
        color: #cbd5e1 !important;
      }
      .custom-list-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 0;
        border-bottom: 1px solid #334155;
      }
      .custom-list-item:last-child {
        border-bottom: none;
      }
    </style>
  </head>
  <body>

    <div class="container py-5">
      <div class="text-center mb-5">
        <h1 class="display-4 fw-bold force-white mb-2">Eslam Harpy</h1>
        <p class="lead force-light-gray fw-semibold">Infrastructure & DevOps Engineer</p>
        <span class="badge badge-devops px-3 py-2">Prometheus & Grafana Capstone Project</span>
      </div>

      <div class="row justify-content-center g-4">
        <div class="col-md-6">
          <div class="card card-custom p-4 shadow-lg text-center h-100 d-flex flex-column justify-content-between">
            <div>
              <h3 class="force-white mb-3">🚀 Live Traffic Simulator</h3>
              <p class="force-light-gray">Click the button below to generate user traffic. Each click triggers a mock HTTP request that Prometheus will scrape via the <code class="text-warning">/metrics</code> endpoint.</p>
            </div>
            
            <div class="my-4">
              <button onclick="generateTraffic()" class="btn btn-primary btn-lg btn-trigger px-5 py-3 fw-bold">
                🎯 Simulate User Request
              </button>
              <div id="statusMessage" class="text-success mt-3 fw-semibold" style="height: 24px;"></div>
            </div>

            <div class="border-top border-secondary pt-3">
              <span class="force-light-gray">Scrape Target: </span>
              <a href="/metrics" target="_blank" class="metrics-link fw-bold">/metrics</a>
            </div>
          </div>
        </div>

        <div class="col-md-6">
          <div class="card card-custom p-4 shadow-lg h-100">
            <h3 class="force-white mb-3">🛠️ Deployment Stack</h3>
            <div class="custom-list-">
              <div class="custom-list-item">
                <span class="force-white fw-medium">Runtime Environment</span>
                <span class="badge bg-success">Node.js / Express</span>
              </div>
              <div class="custom-list-item">
                <span class="force-white fw-medium">Orchestration Cluster</span>
                <span class="badge bg-info text-dark">Kubernetes (k8s)</span>
              </div>
              <div class="custom-list-item">
                <span class="force-white fw-medium">Monitoring Operator</span>
                <span class="badge bg-warning text-dark">kube-prometheus-stack</span>
              </div>
              <div class="custom-list-item">
                <span class="force-white fw-medium">Visualization Layer</span>
                <span class="badge text-white" style="background-color: #f57c00;">Grafana Dashboard</span>
              </div>
            </div>

            <div class="mt-4">
              <h5 class="force-white mb-2 small text-uppercase tracking-wider">Core Metrics Collected:</h5>
              <div class="mt-2">
                <span class="badge badge-tech">http_requests_total (Counter)</span>
                <span class="badge badge-tech">request_duration_seconds (Histogram)</span>
                <span class="badge badge-tech">nodejs_version_info (Gauge)</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="text-center mt-5 force-light-gray small">
        <p>© 2026 Eslam Harpy. Built for Kubernetes GitOps & Monitoring Showcase.</p>
      </div>
    </div>

    <script>
      function generateTraffic() {
        fetch('/api/data')
          .then(response => {
            const msgDiv = document.getElementById('statusMessage');
            msgDiv.innerText = '✅ Request dispatched successfully! (Status: ' + response.status + ')';
            setTimeout(() => { msgDiv.innerText = ''; }, 1500);
          })
          .catch(err => {
            console.error('Error generating traffic:', err);
          });
      }
    </script>
  </body>
  </html>
  `;
  res.send(htmlContent);
});

// 2. Dummy API Route
app.get('/api/data', (req, res) => {
  const delay = Math.floor(Math.random() * 350) + 50;
  setTimeout(() => {
    res.status(200).json({
      status: 'success',
      message: 'Hello from Eslam Harpy\'s backend service!',
      timestamp: new Date().toISOString()
    });
  }, delay);
});

// 3. Metrics Endpoint
app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (ex) {
    res.status(500).end(ex);
  }
});

// Start Server
app.listen(port, () => {
  console.log(`Application is running professionally on port ${port}`);
});
