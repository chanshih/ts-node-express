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
export const proxyRequest = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const protocol = req.query.protocol ? req.query.protocol : "http";
  const host = req.query.host ? req.query.host : "localhost";
  const port = req.query.port ? req.query.port : "8000";
  const path = req.query.path ? req.query.path : "/";
  const url = protocol + "://" + host + ":" + port + path;
  await axios
    .get(url)
    .then((response) => {
      res
        .status(200)
        .send("Sent a request to '" + url + "'\n<hr />\n" + response.data);
    })
    .catch((error) => {
      next(error);
    });
};

// Fibonacci sequence
export const fibonacci = async (req: Request, res: Response) => {
  const n = parseInt(req.query.n as string) || 1;
  const start = Date.now();
  const fib_result = await fib(n);
  const end = Date.now();
  const result = {
    architecture: process.arch,
    fibonacci: { n: n, result: fib_result },
    timeTaken: end - start + " ms",
  };
  res.status(200).send(result);
};

const fib = async (n: number): Promise<number> => {
  if (n <= 1) return n;
  return (await fib(n - 1)) + (await fib(n - 2));
};

// Microservice-specific endpoints
export const getServiceData = async (req: Request, res: Response) => {
  const serviceName = process.env.SERVICE_NAME || 'unknown';
  const port = process.env.PORT || '3000';
  
  const mockData: Record<string, any[]> = {
    'user-service': [{ id: 1, name: 'John Doe', email: 'john@example.com' }],
    'product-service': [{ id: 1, name: 'Laptop', price: 999.99 }],
    'order-service': [{ id: 1, userId: 1, productId: 1, status: 'pending' }],
    'payment-service': [{ id: 1, orderId: 1, amount: 999.99, status: 'completed' }],
    'notification-service': [{ id: 1, message: 'Order confirmed', sent: true }]
  };

  res.json({
    service: serviceName,
    port: port,
    data: mockData[serviceName] || [],
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

export const createServiceData = async (req: Request, res: Response) => {
  const serviceName = process.env.SERVICE_NAME || 'unknown';
  const requestData = req.body;
  
  res.json({
    message: 'Data created successfully',
    service: serviceName,
    data: requestData,
    id: Math.floor(Math.random() * 1000),
    timestamp: new Date().toISOString()
  });
};
