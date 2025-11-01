import {WebSocket, WebSocketServer} from 'ws';
import { NextRequest, NextResponse } from 'next/server';


export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ slug: string }> }
) {
  const { slug } = await params // 'a', 'b', or 'c'
  return proxyRequest(req, slug);
}

export async function POST(
  req: NextRequest,
  { params }: { params: Promise<{ slug: string }> }
) {
  const { slug } = await params // 'a', 'b', or 'c'
  return proxyRequest(req, slug);
}

export async function PUT(
  req: NextRequest,
  { params }: { params: Promise<{ slug: string }> }
) {
  const { slug } = await params // 'a', 'b', or 'c'
  return proxyRequest(req, slug);
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: Promise<{ slug: string }> }
) {
  const { slug } = await params // 'a', 'b', or 'c'
  return proxyRequest(req, slug);
}

async function proxyRequest(req: NextRequest, slug: string) {
  const BACKEND_URL = (process.env.BACKEND_URL || `http://node-server-svc.${process.env.POD_NAMESPACE}.svc.cluster.local`) + '/' + slug;

  const backendResponse = await fetch(BACKEND_URL, {
    method: req.method,
    headers: {
      ...Object.fromEntries(req.headers),
      host: new URL(BACKEND_URL).host,
    },
    body: req.body ? req.body : undefined,
    duplex: "half",
  } as any);

  // Clone the response and return it
  const data = await backendResponse.arrayBuffer();
  return new NextResponse(data, {
    status: backendResponse.status,
    headers: backendResponse.headers,
  });
}

export function UPGRADE(
  client: WebSocket,
  server: WebSocketServer,
  request: NextRequest,
  context: import('next-ws/server').RouteContext<'/backend/[slug]'>,
) {
  const slug = context.params?.slug
  console.log('Client connected to /backend/' + slug)

  // Backend server URL - replace with your actual backend server
  const BACKEND_URL = (process.env.BACKEND_WS_URL || `ws://node-server-svc.${process.env.POD_NAMESPACE}.svc.cluster.local`) + '/' + slug;
  
  console.log('Backend URL:', BACKEND_URL);

  let backendConnection: WebSocket | null = null;
  let isClientClosed = false;
  let isBackendClosed = false;

  // Connect to backend server
  try {
    backendConnection = new WebSocket(BACKEND_URL);
    
    backendConnection.on('open', () => {
      console.log('Connected to backend server');
    });

    backendConnection.on('message', (message) => {
      if (!isClientClosed) {
        client.send(message.toString());
      }
    });

    backendConnection.on('close', (err) => {
      console.log('Backend connection closed', err);
      isBackendClosed = true;
      if (!isClientClosed) {
        client.close();
      }
    });

    backendConnection.on('error', (error) => {
      console.error('Backend connection error:', error);
      if (!isClientClosed) {
        client.close();
      }
    });

  } catch (error) {
    console.error('Failed to connect to backend:', error);
    client.close();
    return;
  }

  // Handle messages from client
  client.on('message', (message) => {
    if (backendConnection && !isBackendClosed) {
      backendConnection.send(message.toString());
    }
  });

  // Handle client disconnect
  client.once('close', () => {
    console.log('A client disconnected');
    isClientClosed = true;
    if (backendConnection && !isBackendClosed) {
      backendConnection.close();
    }
  });

  // Handle client errors
  client.on('error', (error) => {
    console.error('Client connection error:', error);
    isClientClosed = true;
    if (backendConnection && !isBackendClosed) {
      backendConnection.close();
    }
  });
}
