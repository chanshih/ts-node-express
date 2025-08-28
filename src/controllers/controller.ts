import { Request, Response, NextFunction } from "express";
import axios from "axios";
import si from "systeminformation";

const htmlBoilerPlate =
  "<!DOCTYPE html><html><head><title>TS-NODE-EXPRESS</title></head><body>{0}</body></html>";

// Get system information
export const getSysInfo = async (req: Request, res: Response) => {
  let [cpu, mem, graphics, os] = await Promise.all([
    si.cpu(),
    si.mem(),
    si.graphics(),
    si.osInfo(),
  ]);

  let defaultNetworkInterface = await si.networkInterfaces("default");
  let ip_address = defaultNetworkInterface.ip4;
  let network_type = defaultNetworkInterface.type;
  let network_speed = defaultNetworkInterface.speed;

  let graphicsInfo =
    graphics.controllers.length > 0
      ? `${graphics.controllers[0].model} (VRAM: ${graphics.controllers[0].vram})`
      : "";

  var content = "";
  let items = [
    { key: "Host Name", value: os.hostname },
    {
      key: "IP Address",
      value: `${ip_address} (${network_type}, ${network_speed} Mbit / s)`,
    },
    {
      key: "CPU",
      value: `${cpu.manufacturer} ${cpu.brand} ${cpu.speed} GHz (${process.arch})`,
    },
    { key: "Memory", value: `${mem.total / 1000000000} GB` },
    { key: "Graphic", value: graphicsInfo },
    {
      key: "OS",
      value: `${os.distro} ${os.release} ${os.codename} ${os.kernel}`,
    },
  ];
  content += "<table cellpadding='10'>";
  for (var item of items) {
    content +=
      "<tr><td>" + item["key"] + "</td><td>" + item["value"] + "</td></tr>";
  }
  content += "</table>";

  res.status(200).send(htmlBoilerPlate.replace("{0}", content));
};

// Get environment variables
export const getEnvVar = async (req: Request, res: Response) => {
  var envVar =
    "<table cellpadding='10'><tr><th align='left'>Key</th><th align='left'>Value</th></tr>";

  const sortedKeys = Object.keys(process.env).sort();
  for (const key of sortedKeys) {
    envVar += "<tr><td>" + key + "</td><td>" + process.env[key] + "</td></tr>";
  }
  envVar += "</table>";

  res.send(htmlBoilerPlate.replace("{0}", envVar));
};

// Perform a proxy request to another host and path
export const proxyRequest = (
  req: Request,
  res: Response,
  next: NextFunction,
): void => {
  const protocol = req.query.protocol ? req.query.protocol : "http";
  const host = req.query.host ? req.query.host : "localhost";
  const port = req.query.port ? req.query.port : "8000";
  const path = req.query.path ? req.query.path : "/";
  const url = protocol + "://" + host + ":" + port + path;
  
  axios.get(url, { timeout: 5000 })
    .then(response => {
      res.status(200).send("Sent a request to '" + url + "'\n<hr />\n" + response.data);
    })
    .catch((error: any) => {
      if (error.code === 'ECONNREFUSED') {
        res.status(503).json({ error: 'Service unavailable: Connection refused' });
      } else if (error.code === 'ETIMEDOUT') {
        res.status(504).json({ error: 'Gateway timeout: Request timed out' });
      } else {
        res.status(502).json({ error: 'Bad gateway: Proxy request failed' });
      }
    });
};

// Fibonacci sequence
export const fibonacci = (req: Request, res: Response): void => {
  const n = parseInt(req.query.n as string);
  
  if (isNaN(n) || n < 0) {
    res.status(400).json({ error: 'Invalid number parameter. Must be a positive integer.' });
    return;
  }
  
  if (n > 40) {
    res.status(400).json({ error: 'Number too large. Maximum value is 40.' });
    return;
  }
  
  const start = Date.now();
  fib(n).then(fib_result => {
    const end = Date.now();
    const result = {
      architecture: process.arch,
      fibonacci: { n: n, result: fib_result },
      timeTaken: end - start + " ms",
    };
    res.status(200).send(result);
  });
};

const fib = async (n: number): Promise<number> => {
  if (n <= 1) return n;
  return (await fib(n - 1)) + (await fib(n - 2));
};

// Microservice-specific endpoints
export const getServiceData = async (req: Request, res: Response) => {
  const serviceName = process.env.SERVICE_NAME || 'unknown';
  const port = process.env.PORT || '3000';
  const productId = req.params.productId;
  
  const mockData: Record<string, any[]> = {
    'user-service': [{ id: 1, name: 'John Doe', email: 'john@example.com' }],
    'product-service': [{ id: 1, name: 'Laptop', price: 999.99 }, { id: 123, name: 'Test Product', price: 299.99 }],
    'order-service': [{ id: 1, userId: 1, productId: 1, status: 'pending' }],
    'payment-service': [{ id: 1, orderId: 1, amount: 999.99, status: 'completed' }],
    'notification-service': [{ id: 1, message: 'Order confirmed', sent: true }]
  };

  let responseData = mockData[serviceName] || [];
  
  // Handle specific product ID requests
  if (productId && serviceName === 'product-service') {
    const product = responseData.find(p => p.id.toString() === productId);
    if (product) {
      responseData = [product];
    } else {
      res.status(404).json({ error: 'Product not found' });
      return;
    }
  }

  res.json({
    service: serviceName,
    port: port,
    data: responseData,
    timestamp: new Date().toISOString()
  });
};

export const healthCheck = async (req: Request, res: Response) => {
  res.json({ 
    status: 'healthy', 
    service: process.env.SERVICE_NAME || 'unknown',
    timestamp: new Date().toISOString() 
  });
};

export const createServiceData = (req: Request, res: Response): void => {
  const serviceName = process.env.SERVICE_NAME || 'unknown';
  const requestData = req.body;
  
  // Validate request body
  if (!requestData || Object.keys(requestData).length === 0) {
    res.status(400).json({ error: 'Request body is required' });
    return;
  }
  
  // Service-specific validation
  if (serviceName === 'user-service') {
    if (!requestData.name || !requestData.email) {
      res.status(422).json({ error: 'Name and email are required for user service' });
      return;
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(requestData.email)) {
      res.status(422).json({ error: 'Invalid email format' });
      return;
    }
  }
  
  if (serviceName === 'product-service') {
    if (!requestData.name || !requestData.price) {
      res.status(422).json({ error: 'Name and price are required for product service' });
      return;
    }
    if (requestData.price <= 0) {
      res.status(422).json({ error: 'Price must be greater than 0' });
      return;
    }
  }
  
  if (serviceName === 'order-service') {
    if (!requestData.productId || !requestData.quantity) {
      res.status(422).json({ error: 'ProductId and quantity are required for order service' });
      return;
    }
    
    // Always call product service for inventory check
    const productServiceUrl = process.env.PRODUCT_SERVICE_URL || 'http://product-service:3002';
    axios.get(`${productServiceUrl}/api/products/${requestData.productId}`)
      .then(() => {
        // Product service available, proceed with order
        res.status(201).json({
          message: 'Order created successfully',
          service: serviceName,
          data: requestData,
          id: Math.floor(Math.random() * 1000),
          timestamp: new Date().toISOString()
        });
      })
      .catch(() => {
        res.status(503).json({ error: 'Product service unavailable' });
      });
    return;
  }
  
  if (serviceName === 'payment-service') {
    if (!requestData.orderId || !requestData.amount) {
      res.status(422).json({ error: 'OrderId and amount are required for payment service' });
      return;
    }
  }
  
  if (serviceName === 'notification-service') {
    if (!requestData.message) {
      res.status(422).json({ error: 'Message is required for notification service' });
      return;
    }
  }
  
  // Only execute if not order-service with product dependency
  res.status(201).json({
    message: 'Data created successfully',
    service: serviceName,
    data: requestData,
    id: Math.floor(Math.random() * 1000),
    timestamp: new Date().toISOString()
  });
};
