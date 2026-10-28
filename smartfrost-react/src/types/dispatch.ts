export interface DispatchItem {
  id: string;
  batchId?: string;
  coolboxId: string;
  fishType?: string;
  weightKg?: number;
  originLocation?: string;
  destinationLocation?: string;
  supplierName?: string;
  receiverName?: string;
  targetDistributorName?: string;
  targetDistributorEmail?: string;
  status?: string;
  createdAt?: string | { seconds: number; nanoseconds: number };
  latitude?: number;
  longitude?: number;
  frostScore?: number;
  rejectionReason?: string;
  rejectedAt?: string;
}

export type FirebaseConnectionStatus = 'connecting' | 'connected' | 'error';
