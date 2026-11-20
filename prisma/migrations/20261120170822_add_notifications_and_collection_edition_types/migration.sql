/*
  Warnings:

  - The primary key for the `edition_covers` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - A unique constraint covering the columns `[email]` on the table `users` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateEnum
CREATE TYPE "change_proposal_type" AS ENUM ('create', 'update');

-- CreateEnum
CREATE TYPE "change_proposal_status" AS ENUM ('pending', 'approved', 'rejected', 'cancelled');

-- CreateEnum
CREATE TYPE "moderation_decision_type" AS ENUM ('approved', 'rejected');

-- CreateEnum
CREATE TYPE "edition_change_source" AS ENUM ('proposal', 'direct_edit');

-- CreateEnum
CREATE TYPE "collection_visibility" AS ENUM ('public', 'private', 'unlisted');

-- CreateEnum
CREATE TYPE "collection_completeness" AS ENUM ('cib', 'loose', 'sealed');

-- CreateEnum
CREATE TYPE "collection_play_status" AS ENUM ('not_started', 'in_progress', 'completed');

-- CreateEnum
CREATE TYPE "gaming_platform" AS ENUM ('playstation', 'xbox', 'nintendo');

-- CreateEnum
CREATE TYPE "wishlist_priority" AS ENUM ('low', 'normal', 'high');

-- CreateEnum
CREATE TYPE "announcement_status" AS ENUM ('draft', 'published', 'archived');

-- AlterEnum
ALTER TYPE "user_status" ADD VALUE 'deleted';

-- DropIndex
DROP INDEX "edition_contents_edition_id_idx";

-- DropIndex
DROP INDEX "edition_covers_edition_id_key";

-- AlterTable
ALTER TABLE "edition_covers" DROP CONSTRAINT "edition_covers_pkey",
ADD CONSTRAINT "edition_covers_pkey" PRIMARY KEY ("edition_id");

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "deleted_at" TIMESTAMPTZ(6);

-- CreateTable
CREATE TABLE "change_proposals" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "type" "change_proposal_type" NOT NULL,
    "status" "change_proposal_status" NOT NULL DEFAULT 'pending',
    "edition_id" UUID,
    "resulting_edition_id" UUID,
    "collection_item_id" UUID,
    "created_by_id" UUID NOT NULL,
    "proposed_data" JSONB NOT NULL,
    "base_version" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "change_proposals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "moderation_decisions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "proposal_id" UUID NOT NULL,
    "moderator_id" UUID NOT NULL,
    "decision" "moderation_decision_type" NOT NULL,
    "comment" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "moderation_decisions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "edition_change_history" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "edition_id" UUID NOT NULL,
    "proposal_id" UUID,
    "changed_by_id" UUID NOT NULL,
    "source" "edition_change_source" NOT NULL,
    "old_data" JSONB,
    "new_data" JSONB NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "edition_change_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_collections" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "slug" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "visibility" "collection_visibility" NOT NULL DEFAULT 'private',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "user_collections_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "collection_edition_types" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" VARCHAR(100) NOT NULL,
    "slug" VARCHAR(100) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "collection_edition_types_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "collection_items" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "collection_id" UUID NOT NULL,
    "edition_id" UUID,
    "edition_type_id" UUID,
    "condition_grade" INTEGER NOT NULL,
    "completeness" "collection_completeness" NOT NULL,
    "personal_rating" INTEGER,
    "play_status" "collection_play_status" NOT NULL DEFAULT 'not_started',
    "acquired_at" DATE,
    "purchase_price" DECIMAL(12,2),
    "purchase_currency" CHAR(3),
    "estimated_market_value" DECIMAL(12,2),
    "market_value_currency" CHAR(3),
    "valuation_updated_at" TIMESTAMPTZ(6),
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "collection_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "edition_favorites" (
    "user_id" UUID NOT NULL,
    "edition_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "edition_favorites_pkey" PRIMARY KEY ("user_id","edition_id")
);

-- CreateTable
CREATE TABLE "wishlist_items" (
    "user_id" UUID NOT NULL,
    "edition_id" UUID NOT NULL,
    "priority" "wishlist_priority" NOT NULL DEFAULT 'normal',
    "target_price" DECIMAL(12,2),
    "currency" CHAR(3),
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "wishlist_items_pkey" PRIMARY KEY ("user_id","edition_id")
);

-- CreateTable
CREATE TABLE "user_gaming_profiles" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "platform" "gaming_platform" NOT NULL,
    "username" VARCHAR(100) NOT NULL,
    "profile_url" TEXT,
    "is_public" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "user_gaming_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "edition_user_views" (
    "edition_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "first_viewed_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_viewed_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "edition_user_views_pkey" PRIMARY KEY ("edition_id","user_id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "type" VARCHAR(100) NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "message" TEXT NOT NULL,
    "data" JSONB,
    "read_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "announcements" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "created_by_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "message" TEXT NOT NULL,
    "status" "announcement_status" NOT NULL DEFAULT 'draft',
    "published_at" TIMESTAMPTZ(6),
    "expires_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "announcements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "announcement_reads" (
    "announcement_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "read_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "announcement_reads_pkey" PRIMARY KEY ("announcement_id","user_id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "actor_id" UUID,
    "action" VARCHAR(150) NOT NULL,
    "target_type" VARCHAR(100) NOT NULL,
    "target_id" UUID,
    "details" JSONB,
    "ip_address" INET,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "change_proposals_resulting_edition_id_key" ON "change_proposals"("resulting_edition_id");

-- CreateIndex
CREATE INDEX "change_proposals_created_by_id_created_at_idx" ON "change_proposals"("created_by_id", "created_at");

-- CreateIndex
CREATE INDEX "change_proposals_edition_id_status_idx" ON "change_proposals"("edition_id", "status");

-- CreateIndex
CREATE INDEX "change_proposals_status_created_at_idx" ON "change_proposals"("status", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "moderation_decisions_proposal_id_key" ON "moderation_decisions"("proposal_id");

-- CreateIndex
CREATE INDEX "moderation_decisions_moderator_id_created_at_idx" ON "moderation_decisions"("moderator_id", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "edition_change_history_proposal_id_key" ON "edition_change_history"("proposal_id");

-- CreateIndex
CREATE INDEX "edition_change_history_edition_id_created_at_idx" ON "edition_change_history"("edition_id", "created_at");

-- CreateIndex
CREATE INDEX "edition_change_history_changed_by_id_idx" ON "edition_change_history"("changed_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_collections_user_id_key" ON "user_collections"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_collections_slug_key" ON "user_collections"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "collection_edition_types_name_key" ON "collection_edition_types"("name");

-- CreateIndex
CREATE UNIQUE INDEX "collection_edition_types_slug_key" ON "collection_edition_types"("slug");

-- CreateIndex
CREATE INDEX "collection_items_collection_id_idx" ON "collection_items"("collection_id");

-- CreateIndex
CREATE INDEX "collection_items_edition_id_idx" ON "collection_items"("edition_id");

-- CreateIndex
CREATE INDEX "collection_items_edition_type_id_idx" ON "collection_items"("edition_type_id");

-- CreateIndex
CREATE INDEX "edition_favorites_edition_id_idx" ON "edition_favorites"("edition_id");

-- CreateIndex
CREATE INDEX "wishlist_items_edition_id_idx" ON "wishlist_items"("edition_id");

-- CreateIndex
CREATE INDEX "user_gaming_profiles_platform_username_idx" ON "user_gaming_profiles"("platform", "username");

-- CreateIndex
CREATE UNIQUE INDEX "user_gaming_profiles_user_id_platform_key" ON "user_gaming_profiles"("user_id", "platform");

-- CreateIndex
CREATE INDEX "edition_user_views_user_id_last_viewed_at_idx" ON "edition_user_views"("user_id", "last_viewed_at");

-- CreateIndex
CREATE INDEX "notifications_user_id_created_at_idx" ON "notifications"("user_id", "created_at");

-- CreateIndex
CREATE INDEX "notifications_user_id_read_at_created_at_idx" ON "notifications"("user_id", "read_at", "created_at");

-- CreateIndex
CREATE INDEX "announcements_status_published_at_idx" ON "announcements"("status", "published_at");

-- CreateIndex
CREATE INDEX "announcements_expires_at_idx" ON "announcements"("expires_at");

-- CreateIndex
CREATE INDEX "announcement_reads_user_id_read_at_idx" ON "announcement_reads"("user_id", "read_at");

-- CreateIndex
CREATE INDEX "audit_logs_actor_id_created_at_idx" ON "audit_logs"("actor_id", "created_at");

-- CreateIndex
CREATE INDEX "audit_logs_target_type_target_id_idx" ON "audit_logs"("target_type", "target_id");

-- CreateIndex
CREATE INDEX "audit_logs_created_at_idx" ON "audit_logs"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- AddForeignKey
ALTER TABLE "change_proposals" ADD CONSTRAINT "change_proposals_edition_id_fkey" FOREIGN KEY ("edition_id") REFERENCES "editions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "change_proposals" ADD CONSTRAINT "change_proposals_resulting_edition_id_fkey" FOREIGN KEY ("resulting_edition_id") REFERENCES "editions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "change_proposals" ADD CONSTRAINT "change_proposals_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "change_proposals" ADD CONSTRAINT "change_proposals_collection_item_id_fkey" FOREIGN KEY ("collection_item_id") REFERENCES "collection_items"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "moderation_decisions" ADD CONSTRAINT "moderation_decisions_proposal_id_fkey" FOREIGN KEY ("proposal_id") REFERENCES "change_proposals"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "moderation_decisions" ADD CONSTRAINT "moderation_decisions_moderator_id_fkey" FOREIGN KEY ("moderator_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "edition_change_history" ADD CONSTRAINT "edition_change_history_edition_id_fkey" FOREIGN KEY ("edition_id") REFERENCES "editions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "edition_change_history" ADD CONSTRAINT "edition_change_history_proposal_id_fkey" FOREIGN KEY ("proposal_id") REFERENCES "change_proposals"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "edition_change_history" ADD CONSTRAINT "edition_change_history_changed_by_id_fkey" FOREIGN KEY ("changed_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_collections" ADD CONSTRAINT "user_collections_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "collection_items" ADD CONSTRAINT "collection_items_collection_id_fkey" FOREIGN KEY ("collection_id") REFERENCES "user_collections"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "collection_items" ADD CONSTRAINT "collection_items_edition_id_fkey" FOREIGN KEY ("edition_id") REFERENCES "editions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "collection_items" ADD CONSTRAINT "collection_items_edition_type_id_fkey" FOREIGN KEY ("edition_type_id") REFERENCES "collection_edition_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "edition_favorites" ADD CONSTRAINT "edition_favorites_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "edition_favorites" ADD CONSTRAINT "edition_favorites_edition_id_fkey" FOREIGN KEY ("edition_id") REFERENCES "editions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wishlist_items" ADD CONSTRAINT "wishlist_items_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wishlist_items" ADD CONSTRAINT "wishlist_items_edition_id_fkey" FOREIGN KEY ("edition_id") REFERENCES "editions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_gaming_profiles" ADD CONSTRAINT "user_gaming_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "edition_user_views" ADD CONSTRAINT "edition_user_views_edition_id_fkey" FOREIGN KEY ("edition_id") REFERENCES "editions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "edition_user_views" ADD CONSTRAINT "edition_user_views_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "announcements" ADD CONSTRAINT "announcements_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "announcement_reads" ADD CONSTRAINT "announcement_reads_announcement_id_fkey" FOREIGN KEY ("announcement_id") REFERENCES "announcements"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "announcement_reads" ADD CONSTRAINT "announcement_reads_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_actor_id_fkey" FOREIGN KEY ("actor_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
