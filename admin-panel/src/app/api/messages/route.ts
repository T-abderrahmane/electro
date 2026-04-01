import { NextRequest, NextResponse } from 'next/server';
import { getDatabase, saveDatabase } from '@/lib/database';

// OPTIONS - CORS preflight
export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  });
}

// GET /api/messages
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const requestId = searchParams.get('requestId');
  const senderId = searchParams.get('senderId');
  const receiverId = searchParams.get('receiverId');
  
  const db = await getDatabase();
  let messages = db.messages;
  
  if (requestId) {
    messages = messages.filter(m => m.requestId === requestId);
  }
  
  if (senderId) {
    messages = messages.filter(m => m.senderId === senderId || m.receiverId === senderId);
  }
  
  if (receiverId) {
    messages = messages.filter(m => m.receiverId === receiverId || m.senderId === receiverId);
  }
  
  // Sort by creation date
  messages.sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime());
  
  return NextResponse.json(messages);
}

// POST /api/messages
export async function POST(request: NextRequest) {
  const body = await request.json();
  const db = await getDatabase();
  
  const newMessage = {
    id: `m${Date.now()}`,
    ...body,
    isRead: false,
    createdAt: new Date().toISOString(),
  };
  
  db.messages.push(newMessage);
  await saveDatabase(db);
  
  return NextResponse.json(newMessage, { status: 201 });
}
