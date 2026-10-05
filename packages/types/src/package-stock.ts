import type { ISODateString, MoneyString, UUID } from "./common";
export interface PackageStock { id:UUID; packageId:UUID; unitPrice:MoneyString; receivedAt:ISODateString; notes:string|null; createdBy:UUID|null; createdAt:ISODateString; }
export interface PackageStockSummary extends PackageStock { currentQuantity:number; }
