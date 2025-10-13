import {WebSocket, WebSocketServer} from 'ws';
import { NextRequest } from 'next/server';

export function GET() {
  const headers = new Headers();
  headers.set('Connection', 'Upgrade');
  headers.set('Upgrade', 'websocket');
  return new Response('Upgrade Required', { status: 426, headers });
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