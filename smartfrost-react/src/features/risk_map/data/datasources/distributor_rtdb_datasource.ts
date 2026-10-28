import { ref, onValue, type DataSnapshot } from 'firebase/database';
import { rtdb } from '../../../../firebase';

export interface RtdbDistributor {
  id: string;
  name: string;
  storeLocation: string;
  latitude: number;
  longitude: number;
  organization?: string;
  email?: string;
  role?: string;
}

/**
 * Subscribes to the pure `distributors` table in Firebase Realtime Database.
 * No dummy or fictional locations are injected.
 */
export class DistributorRtdbDatasource {
  static subscribeToDistributors(
    onSuccess: (distributors: RtdbDistributor[], isLive: boolean) => void,
    onError: (err: unknown) => void
  ) {
    try {
      return onValue(
        ref(rtdb, 'distributors'),
        (snapshot: DataSnapshot) => {
          if (snapshot.exists()) {
            const raw = snapshot.val() as Record<string, Record<string, unknown>>;
            const list: RtdbDistributor[] = Object.entries(raw)
              .filter(([, v]) => v && typeof v === 'object')
              .map(([key, d]) => {
                const name = String(d.name || d.storeLocation || key).trim();
                const storeLocation = String(d.storeLocation || d.location || name).trim();
                const lat = typeof d.latitude === 'number' ? d.latitude : 0;
                const lng = typeof d.longitude === 'number' ? d.longitude : 0;

                return {
                  id: key,
                  name,
                  storeLocation,
                  latitude: lat,
                  longitude: lng,
                  organization: typeof d.organization === 'string' ? d.organization : undefined,
                  email: typeof d.email === 'string' ? d.email : undefined,
                  role: typeof d.role === 'string' ? d.role : 'distributor',
                };
              })
              // Filter out entries with invalid coordinates
              .filter((d) => d.latitude !== 0 && d.longitude !== 0);

            onSuccess(list, true);
          } else {
            onSuccess([], false);
          }
        },
        (error) => {
          console.warn('Realtime Database distributors listener notice:', error);
          onError(error);
          onSuccess([], false);
        }
      );
    } catch (err) {
      onError(err);
      onSuccess([], false);
      return () => {};
    }
  }
}
