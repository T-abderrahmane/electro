import fs from 'fs/promises';
import path from 'path';

export interface User {
  id: string;
  name: string;
  phone: string;
  role: 'client' | 'electrician';
  wilaya?: string;
  commune?: string;
  yearsExperience?: number;
  specialties?: string[];
  profileImage?: string;
  createdAt: string;
  accountStatus: 'active' | 'suspended';
  subscriptionStatus?: 'active' | 'pending' | 'inactive' | 'expired';
  subscriptionStartDate?: string;
  subscriptionEndDate?: string;
  rating?: number;
  completedJobs?: number;
}

export interface ServiceRequest {
  id: string;
  clientId: string;
  clientName: string;
  clientPhone: string;
  serviceType: 'installation' | 'repair' | 'maintenance' | 'consultation' | 'other';
  description: string;
  wilaya: string;
  commune: string;
  address?: string;
  images?: string[];
  status: 'pending' | 'open' | 'assigned' | 'in_progress' | 'completed' | 'closed' | 'cancelled';
  assignedElectricianId?: string;
  createdAt: string;
  preferredDate?: string;
}

export interface Offer {
  id: string;
  requestId: string;
  electricianId: string;
  electricianName: string;
  price: number;
  description: string;
  estimatedDuration: string;
  status: 'pending' | 'accepted' | 'rejected';
  createdAt: string;
}

export interface ChatMessage {
  id: string;
  requestId: string;
  senderId: string;
  receiverId: string;
  message: string;
  createdAt: string;
  isRead: boolean;
}

export interface SubscriptionPayment {
  id: string;
  electricianId: string;
  electricianName: string;
  amount: number;
  paymentMethod: string;
  transactionId: string;
  screenshotUrl?: string;
  status: 'pending' | 'approved' | 'rejected';
  createdAt: string;
}

export interface Database {
  users: User[];
  requests: ServiceRequest[];
  offers: Offer[];
  messages: ChatMessage[];
  payments: SubscriptionPayment[];
}

const DB_PATH = path.join(process.cwd(), 'data', 'database.json');

// Initial mock data
const initialData: Database = {
  users: [
    {
      id: 'c1',
      name: 'أحمد محمد',
      phone: '0550123456',
      role: 'client',
      wilaya: 'الجزائر',
      commune: 'باب الزوار',
      createdAt: '2024-01-15T10:00:00Z',
      accountStatus: 'active',
    },
    {
      id: 'c2',
      name: 'محمد علي',
      phone: '0551234567',
      role: 'client',
      wilaya: 'وهران',
      commune: 'وهران المدينة',
      createdAt: '2024-02-20T14:30:00Z',
      accountStatus: 'active',
    },
    {
      id: 'e1',
      name: 'كريم حسني',
      phone: '0660123456',
      role: 'electrician',
      wilaya: 'الجزائر',
      commune: 'باب الزوار',
      yearsExperience: 8,
      specialties: ['installation', 'repair'],
      createdAt: '2024-01-10T09:00:00Z',
      accountStatus: 'active',
      subscriptionStatus: 'active',
      subscriptionStartDate: '2024-03-01',
      subscriptionEndDate: '2024-04-01',
      rating: 4.8,
      completedJobs: 45,
    },
    {
      id: 'e2',
      name: 'سعيد أحمد',
      phone: '0661234567',
      role: 'electrician',
      wilaya: 'الجزائر',
      commune: 'الدار البيضاء',
      yearsExperience: 5,
      specialties: ['maintenance', 'consultation'],
      createdAt: '2024-01-20T11:00:00Z',
      accountStatus: 'active',
      subscriptionStatus: 'inactive',
      rating: 4.5,
      completedJobs: 28,
    },
    {
      id: 'e3',
      name: 'يوسف خالد',
      phone: '0662345678',
      role: 'electrician',
      wilaya: 'وهران',
      commune: 'وهران المدينة',
      yearsExperience: 12,
      specialties: ['installation', 'repair', 'maintenance'],
      createdAt: '2024-02-01T08:00:00Z',
      accountStatus: 'active',
      subscriptionStatus: 'active',
      subscriptionStartDate: '2024-02-15',
      subscriptionEndDate: '2024-03-15',
      rating: 4.9,
      completedJobs: 87,
    },
  ],
  requests: [
    {
      id: 'r1',
      clientId: 'c1',
      clientName: 'أحمد محمد',
      clientPhone: '0550123456',
      serviceType: 'repair',
      description: 'مشكلة في الكهرباء، الأضواء تنطفئ بشكل متكرر',
      wilaya: 'الجزائر',
      commune: 'باب الزوار',
      address: 'شارع الاستقلال، رقم 25',
      status: 'open',
      createdAt: '2024-03-01T10:00:00Z',
    },
    {
      id: 'r2',
      clientId: 'c1',
      clientName: 'أحمد محمد',
      clientPhone: '0550123456',
      serviceType: 'installation',
      description: 'تركيب لوحة كهربائية جديدة في المنزل',
      wilaya: 'الجزائر',
      commune: 'باب الزوار',
      status: 'assigned',
      assignedElectricianId: 'e1',
      createdAt: '2024-02-28T14:00:00Z',
    },
    {
      id: 'r3',
      clientId: 'c2',
      clientName: 'محمد علي',
      clientPhone: '0551234567',
      serviceType: 'maintenance',
      description: 'صيانة دورية للتمديدات الكهربائية',
      wilaya: 'وهران',
      commune: 'وهران المدينة',
      status: 'pending',
      createdAt: '2024-03-02T09:00:00Z',
    },
  ],
  offers: [
    {
      id: 'o1',
      requestId: 'r1',
      electricianId: 'e1',
      electricianName: 'كريم حسني',
      price: 3500,
      description: 'سأقوم بفحص المشكلة وإصلاحها. الضمان 3 أشهر.',
      estimatedDuration: '2-3 ساعات',
      status: 'pending',
      createdAt: '2024-03-01T11:00:00Z',
    },
    {
      id: 'o2',
      requestId: 'r1',
      electricianId: 'e2',
      electricianName: 'سعيد أحمد',
      price: 4000,
      description: 'فحص شامل وإصلاح مع ضمان 6 أشهر.',
      estimatedDuration: '3-4 ساعات',
      status: 'pending',
      createdAt: '2024-03-01T12:00:00Z',
    },
    {
      id: 'o3',
      requestId: 'r2',
      electricianId: 'e1',
      electricianName: 'كريم حسني',
      price: 15000,
      description: 'تركيب لوحة كهربائية جديدة مع جميع المواد.',
      estimatedDuration: 'يوم واحد',
      status: 'accepted',
      createdAt: '2024-02-28T15:00:00Z',
    },
  ],
  messages: [],
  payments: [
    {
      id: 'p1',
      electricianId: 'e2',
      electricianName: 'سعيد أحمد',
      amount: 3000,
      paymentMethod: 'BaridiMob',
      transactionId: 'BM123456789',
      status: 'pending',
      createdAt: '2024-03-01T10:00:00Z',
    },
  ],
};

export async function getDatabase(): Promise<Database> {
  try {
    // Ensure data directory exists
    const dataDir = path.dirname(DB_PATH);
    try {
      await fs.access(dataDir);
    } catch {
      await fs.mkdir(dataDir, { recursive: true });
    }

    // Try to read existing database
    try {
      const data = await fs.readFile(DB_PATH, 'utf-8');
      return JSON.parse(data);
    } catch {
      // If file doesn't exist, create with initial data
      await fs.writeFile(DB_PATH, JSON.stringify(initialData, null, 2));
      return initialData;
    }
  } catch (error) {
    console.error('Database error:', error);
    return initialData;
  }
}

export async function saveDatabase(db: Database): Promise<void> {
  try {
    const dataDir = path.dirname(DB_PATH);
    try {
      await fs.access(dataDir);
    } catch {
      await fs.mkdir(dataDir, { recursive: true });
    }
    await fs.writeFile(DB_PATH, JSON.stringify(db, null, 2));
  } catch (error) {
    console.error('Failed to save database:', error);
    throw error;
  }
}
