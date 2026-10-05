-- CreateEnum
CREATE TYPE "EntityStatus" AS ENUM ('ACTIVE', 'INACTIVE');

-- CreateEnum
CREATE TYPE "SaleStatus" AS ENUM ('ACTIVE', 'CANCELLED');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('ACTIVE', 'REVERSED');

-- CreateEnum
CREATE TYPE "LinePaymentStatus" AS ENUM ('ACTIVE', 'REVERSED');

-- CreateEnum
CREATE TYPE "ExpenseStatus" AS ENUM ('ACTIVE', 'REVERSED');

-- CreateEnum
CREATE TYPE "OwnerWithdrawalStatus" AS ENUM ('ACTIVE', 'REVERSED');

-- CreateEnum
CREATE TYPE "InventoryMovementType" AS ENUM ('ADD', 'SELL', 'RETURN', 'ADJUSTMENT');

-- CreateEnum
CREATE TYPE "CashDirection" AS ENUM ('IN', 'OUT');

-- CreateEnum
CREATE TYPE "CashSourceType" AS ENUM ('OPENING', 'SALE_PAYMENT', 'SALE_PAYMENT_REVERSAL', 'EXPENSE', 'EXPENSE_REVERSAL', 'LINE_PAYMENT', 'LINE_PAYMENT_REVERSAL', 'OWNER_WITHDRAWAL', 'OWNER_WITHDRAWAL_REVERSAL', 'MANUAL');

-- CreateEnum
CREATE TYPE "AuditAction" AS ENUM ('PACKAGE_CREATED', 'PACKAGE_UPDATED', 'INVENTORY_ADDED', 'INVENTORY_ADJUSTED', 'INVENTORY_RETURNED', 'INVENTORY_BATCH_UPDATED', 'INVENTORY_BATCH_DELETED', 'DISTRIBUTOR_CREATED', 'DISTRIBUTOR_UPDATED', 'DISTRIBUTOR_ACTIVATED', 'DISTRIBUTOR_DEACTIVATED', 'SALE_CREATED', 'SALE_CANCELLED', 'SALE_UPDATED', 'PAYMENT_CREATED', 'PAYMENT_UPDATED', 'PAYMENT_DELETED', 'PAYMENT_REVERSED', 'LINE_CREATED', 'LINE_UPDATED', 'LINE_ACTIVATED', 'LINE_DEACTIVATED', 'LINE_PAYMENT_CREATED', 'LINE_PAYMENT_UPDATED', 'LINE_PAYMENT_DELETED', 'LINE_PAYMENT_REVERSED', 'LINE_DELETED', 'EXPENSE_CREATED', 'EXPENSE_UPDATED', 'EXPENSE_REVERSED', 'EXPENSE_DELETED', 'EXPENSE_CATEGORY_CREATED', 'EXPENSE_CATEGORY_UPDATED', 'EXPENSE_CATEGORY_ACTIVATED', 'EXPENSE_CATEGORY_DEACTIVATED', 'EXPENSE_CATEGORY_DELETED', 'OWNER_WITHDRAWAL_CREATED', 'OWNER_WITHDRAWAL_UPDATED', 'OWNER_WITHDRAWAL_DELETED', 'OWNER_WITHDRAWAL_REVERSED', 'CASH_MANUAL_IN', 'CASH_MANUAL_OUT', 'CASH_CLOSING_CREATED', 'BACKUP_CREATED', 'BACKUP_RESTORED', 'BACKUP_EXPORTED', 'BACKUP_DELETED', 'BACKUPS_PURGED', 'SETTINGS_UPDATED');

-- CreateTable
CREATE TABLE "packages" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "price" DECIMAL(12,2) NOT NULL,
    "data_size_mb" INTEGER NOT NULL,
    "hours" INTEGER NOT NULL,
    "color" TEXT,
    "status" "EntityStatus" NOT NULL DEFAULT 'ACTIVE',
    "description" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "packages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "package_stocks" (
    "id" UUID NOT NULL,
    "package_id" UUID NOT NULL,
    "unit_price" DECIMAL(12,2) NOT NULL,
    "received_at" TIMESTAMPTZ(6) NOT NULL,
    "notes" TEXT,
    "created_by" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "package_stocks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "inventory_movements" (
    "id" UUID NOT NULL,
    "package_stock_id" UUID NOT NULL,
    "type" "InventoryMovementType" NOT NULL,
    "quantity_delta" INTEGER NOT NULL,
    "unit_price" DECIMAL(12,2) NOT NULL,
    "reference_type" TEXT,
    "reference_id" UUID,
    "description" TEXT,
    "created_by" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "inventory_movements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "distributors" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "address" TEXT,
    "notes" TEXT,
    "status" "EntityStatus" NOT NULL DEFAULT 'ACTIVE',
    "registration_date" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "distributors_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sales" (
    "id" UUID NOT NULL,
    "invoice_number" TEXT NOT NULL,
    "distributor_id" UUID NOT NULL,
    "total_amount" DECIMAL(12,2) NOT NULL,
    "status" "SaleStatus" NOT NULL DEFAULT 'ACTIVE',
    "sale_date" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "notes" TEXT,
    "created_by" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "cancelled_at" TIMESTAMPTZ(6),
    "cancelled_by" TEXT,
    "cancellation_reason" TEXT,

    CONSTRAINT "sales_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sale_items" (
    "id" UUID NOT NULL,
    "sale_id" UUID NOT NULL,
    "package_id" UUID NOT NULL,
    "package_name_snapshot" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL,
    "unit_price" DECIMAL(12,2) NOT NULL,
    "total_price" DECIMAL(12,2) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sale_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payments" (
    "id" UUID NOT NULL,
    "sale_id" UUID NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "status" "PaymentStatus" NOT NULL DEFAULT 'ACTIVE',
    "payment_date" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "notes" TEXT,
    "created_by" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reversed_at" TIMESTAMPTZ(6),
    "reversed_by" TEXT,
    "reversal_reason" TEXT,

    CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lines" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "identifier" TEXT NOT NULL,
    "speed" TEXT,
    "cost" DECIMAL(12,2) NOT NULL,
    "status" "EntityStatus" NOT NULL DEFAULT 'ACTIVE',
    "subscription_date" TIMESTAMPTZ(6) NOT NULL,
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "line_payments" (
    "id" UUID NOT NULL,
    "line_id" UUID NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "period" TEXT NOT NULL,
    "status" "LinePaymentStatus" NOT NULL DEFAULT 'ACTIVE',
    "payment_date" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "notes" TEXT,
    "created_by" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reversed_at" TIMESTAMPTZ(6),
    "reversed_by" TEXT,
    "reversal_reason" TEXT,

    CONSTRAINT "line_payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "expense_categories" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "expense_categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "expenses" (
    "id" UUID NOT NULL,
    "category_id" UUID NOT NULL,
    "description" TEXT NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "status" "ExpenseStatus" NOT NULL DEFAULT 'ACTIVE',
    "expense_date" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "notes" TEXT,
    "created_by" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "reversed_at" TIMESTAMPTZ(6),
    "reversed_by" TEXT,
    "reversal_reason" TEXT,

    CONSTRAINT "expenses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "owner_withdrawals" (
    "id" UUID NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "reason" TEXT NOT NULL,
    "status" "OwnerWithdrawalStatus" NOT NULL DEFAULT 'ACTIVE',
    "withdrawal_date" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "notes" TEXT,
    "created_by" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reversed_at" TIMESTAMPTZ(6),
    "reversed_by" TEXT,
    "reversal_reason" TEXT,

    CONSTRAINT "owner_withdrawals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cash_movements" (
    "id" UUID NOT NULL,
    "direction" "CashDirection" NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "source_type" "CashSourceType" NOT NULL,
    "source_id" UUID,
    "description" TEXT,
    "movement_date" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "cash_movements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cash_closings" (
    "id" UUID NOT NULL,
    "closing_date" DATE NOT NULL,
    "opening_balance" DECIMAL(12,2) NOT NULL,
    "total_in" DECIMAL(12,2) NOT NULL,
    "total_out" DECIMAL(12,2) NOT NULL,
    "owner_withdrawals" DECIMAL(12,2) NOT NULL,
    "expected_balance" DECIMAL(12,2) NOT NULL,
    "actual_balance" DECIMAL(12,2) NOT NULL,
    "difference" DECIMAL(12,2) NOT NULL,
    "notes" TEXT,
    "closed_by" TEXT,
    "closed_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "cash_closings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" UUID NOT NULL,
    "user_id" TEXT,
    "action" "AuditAction" NOT NULL,
    "entity_type" TEXT NOT NULL,
    "entity_id" UUID,
    "old_values" JSONB,
    "new_values" JSONB,
    "ip_address" TEXT,
    "user_agent" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "backups" (
    "id" UUID NOT NULL,
    "file_name" TEXT NOT NULL,
    "storage_path" TEXT NOT NULL,
    "size_bytes" BIGINT NOT NULL,
    "record_count" INTEGER NOT NULL,
    "checksum" TEXT NOT NULL,
    "created_by" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "backups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "settings" (
    "id" UUID NOT NULL,
    "singleton_key" TEXT NOT NULL DEFAULT 'main',
    "network_name" TEXT NOT NULL,
    "currency_name" TEXT NOT NULL,
    "currency_symbol" TEXT NOT NULL,
    "admin_email" TEXT NOT NULL,
    "low_stock_threshold" INTEGER NOT NULL DEFAULT 10,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "settings_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "packages_name_key" ON "packages"("name");

-- CreateIndex
CREATE INDEX "packages_status_idx" ON "packages"("status");

-- CreateIndex
CREATE INDEX "package_stocks_package_id_idx" ON "package_stocks"("package_id");

-- CreateIndex
CREATE INDEX "package_stocks_received_at_idx" ON "package_stocks"("received_at");

-- CreateIndex
CREATE INDEX "package_stocks_created_at_idx" ON "package_stocks"("created_at");

-- CreateIndex
CREATE INDEX "inventory_movements_package_stock_id_idx" ON "inventory_movements"("package_stock_id");

-- CreateIndex
CREATE INDEX "inventory_movements_type_idx" ON "inventory_movements"("type");

-- CreateIndex
CREATE INDEX "inventory_movements_reference_type_reference_id_idx" ON "inventory_movements"("reference_type", "reference_id");

-- CreateIndex
CREATE INDEX "inventory_movements_created_at_idx" ON "inventory_movements"("created_at");

-- CreateIndex
CREATE INDEX "distributors_name_idx" ON "distributors"("name");

-- CreateIndex
CREATE INDEX "distributors_phone_idx" ON "distributors"("phone");

-- CreateIndex
CREATE INDEX "distributors_status_idx" ON "distributors"("status");

-- CreateIndex
CREATE UNIQUE INDEX "sales_invoice_number_key" ON "sales"("invoice_number");

-- CreateIndex
CREATE INDEX "sales_distributor_id_idx" ON "sales"("distributor_id");

-- CreateIndex
CREATE INDEX "sales_sale_date_idx" ON "sales"("sale_date");

-- CreateIndex
CREATE INDEX "sales_status_idx" ON "sales"("status");

-- CreateIndex
CREATE INDEX "sale_items_sale_id_idx" ON "sale_items"("sale_id");

-- CreateIndex
CREATE INDEX "sale_items_package_id_idx" ON "sale_items"("package_id");

-- CreateIndex
CREATE INDEX "payments_sale_id_idx" ON "payments"("sale_id");

-- CreateIndex
CREATE INDEX "payments_payment_date_idx" ON "payments"("payment_date");

-- CreateIndex
CREATE INDEX "payments_status_idx" ON "payments"("status");

-- CreateIndex
CREATE INDEX "lines_status_idx" ON "lines"("status");

-- CreateIndex
CREATE INDEX "lines_identifier_idx" ON "lines"("identifier");

-- CreateIndex
CREATE INDEX "line_payments_line_id_idx" ON "line_payments"("line_id");

-- CreateIndex
CREATE INDEX "line_payments_payment_date_idx" ON "line_payments"("payment_date");

-- CreateIndex
CREATE INDEX "line_payments_status_idx" ON "line_payments"("status");

-- CreateIndex
CREATE UNIQUE INDEX "expense_categories_name_key" ON "expense_categories"("name");

-- CreateIndex
CREATE INDEX "expenses_category_id_idx" ON "expenses"("category_id");

-- CreateIndex
CREATE INDEX "expenses_expense_date_idx" ON "expenses"("expense_date");

-- CreateIndex
CREATE INDEX "expenses_status_idx" ON "expenses"("status");

-- CreateIndex
CREATE INDEX "owner_withdrawals_withdrawal_date_idx" ON "owner_withdrawals"("withdrawal_date");

-- CreateIndex
CREATE INDEX "owner_withdrawals_status_idx" ON "owner_withdrawals"("status");

-- CreateIndex
CREATE INDEX "cash_movements_source_type_idx" ON "cash_movements"("source_type");

-- CreateIndex
CREATE INDEX "cash_movements_source_type_source_id_idx" ON "cash_movements"("source_type", "source_id");

-- CreateIndex
CREATE INDEX "cash_movements_movement_date_idx" ON "cash_movements"("movement_date");

-- CreateIndex
CREATE INDEX "cash_movements_direction_idx" ON "cash_movements"("direction");

-- CreateIndex
CREATE UNIQUE INDEX "cash_closings_closing_date_key" ON "cash_closings"("closing_date");

-- CreateIndex
CREATE INDEX "cash_closings_closing_date_idx" ON "cash_closings"("closing_date");

-- CreateIndex
CREATE INDEX "audit_logs_entity_type_entity_id_idx" ON "audit_logs"("entity_type", "entity_id");

-- CreateIndex
CREATE INDEX "audit_logs_created_at_idx" ON "audit_logs"("created_at");

-- CreateIndex
CREATE INDEX "audit_logs_action_idx" ON "audit_logs"("action");

-- CreateIndex
CREATE INDEX "backups_created_at_idx" ON "backups"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "settings_singleton_key_key" ON "settings"("singleton_key");

-- AddForeignKey
ALTER TABLE "package_stocks" ADD CONSTRAINT "package_stocks_package_id_fkey" FOREIGN KEY ("package_id") REFERENCES "packages"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory_movements" ADD CONSTRAINT "inventory_movements_package_stock_id_fkey" FOREIGN KEY ("package_stock_id") REFERENCES "package_stocks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales" ADD CONSTRAINT "sales_distributor_id_fkey" FOREIGN KEY ("distributor_id") REFERENCES "distributors"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sale_items" ADD CONSTRAINT "sale_items_sale_id_fkey" FOREIGN KEY ("sale_id") REFERENCES "sales"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sale_items" ADD CONSTRAINT "sale_items_package_id_fkey" FOREIGN KEY ("package_id") REFERENCES "packages"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_sale_id_fkey" FOREIGN KEY ("sale_id") REFERENCES "sales"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "line_payments" ADD CONSTRAINT "line_payments_line_id_fkey" FOREIGN KEY ("line_id") REFERENCES "lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "expense_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
