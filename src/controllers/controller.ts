import { Request, Response, NextFunction } from "express";
import axios from "axios";
import si from "systeminformation";

const htmlBoilerPlate =
  "<!DOCTYPE html><html><head><title>TS-NODE-EXPRESS</title></head><body>{0}</body></html>";

// Get system information
export const getSysInfo = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
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
  } catch (error) {
    next(error);
  }
};

// Get environment variables
export const getEnvVar = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    var envVar =
      "<table cellpadding='10'><tr><th align='left'>Key</th><th align='left'>Value</th></tr>";

    const sortedKeys = Object.keys(process.env).sort();
    for (const key of sortedKeys) {
      envVar +=
        "<tr><td>" + key + "</td><td>" + process.env[key] + "</td></tr>";
    }
    envVar += "</table>";

    res.send(htmlBoilerPlate.replace("{0}", envVar));
  } catch (error) {
    next(error);
  }
};

// Redirects to another host and path
export const redirect = async (
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
