-- CreateEnum
CREATE TYPE "edition_type" AS ENUM ('standard', 'compilation');

-- CreateEnum
CREATE TYPE "language_status" AS ENUM ('known', 'none', 'unknown');

-- CreateEnum
CREATE TYPE "download_requirement" AS ENUM ('yes', 'no', 'recommended', 'unknown');

-- CreateEnum
CREATE TYPE "internet_requirement" AS ENUM ('required', 'not_required', 'online_modes_only', 'unknown');

-- CreateEnum
CREATE TYPE "language_type" AS ENUM ('audio', 'text');

-- CreateEnum
CREATE TYPE "edition_content_type" AS ENUM ('game', 'dlc');

-- CreateTable
CREATE TABLE "platforms" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" VARCHAR(100) NOT NULL,
    "slug" VARCHAR(120) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "platforms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "regions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" VARCHAR(100) NOT NULL,
    "slug" VARCHAR(120) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "regions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rating_systems" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" VARCHAR(100) NOT NULL,
    "slug" VARCHAR(120) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "rating_systems_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "region_rating_systems" (
    "region_id" UUID NOT NULL,
    "rating_system_id" UUID NOT NULL,

    CONSTRAINT "region_rating_systems_pkey" PRIMARY KEY ("region_id","rating_system_id")
);

-- CreateTable
CREATE TABLE "publishers" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" VARCHAR(150) NOT NULL,
    "slug" VARCHAR(170) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "publishers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "languages" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "code" VARCHAR(35) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "languages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "editions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" VARCHAR(255) NOT NULL,
    "slug" VARCHAR(280) NOT NULL,
    "edition_type" "edition_type" NOT NULL,
    "platform_id" UUID NOT NULL,
    "region_id" UUID NOT NULL,
    "rating_system_id" UUID NOT NULL,
    "publisher_id" UUID,
    "release_year" INTEGER,
    "product_code" VARCHAR(50),
    "spine_code" VARCHAR(50),
    "barcode" VARCHAR(50),
    "audio_language_status" "language_status" NOT NULL DEFAULT 'unknown',
    "text_language_status" "language_status" NOT NULL DEFAULT 'unknown',
    "description" TEXT,
    "requires_download" "download_requirement" NOT NULL DEFAULT 'unknown',
    "internet_requirement" "internet_requirement" NOT NULL DEFAULT 'unknown',
    "technical_notes" TEXT,
    "version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "editions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "edition_languages" (
    "edition_id" UUID NOT NULL,
    "language_id" UUID NOT NULL,
    "type" "language_type" NOT NULL,

    CONSTRAINT "edition_languages_pkey" PRIMARY KEY ("edition_id","language_id","type")
);

-- CreateTable
CREATE TABLE "edition_content_languages" (
    "edition_content_id" UUID NOT NULL,
    "language_id" UUID NOT NULL,
    "type" "language_type" NOT NULL,

    CONSTRAINT "edition_content_languages_pkey" PRIMARY KEY ("edition_content_id","language_id","type")
);

-- CreateTable
CREATE TABLE "edition_contents" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "edition_id" UUID NOT NULL,
    "type" "edition_content_type" NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "position" INTEGER NOT NULL,
    "audio_language_status" "language_status" NOT NULL DEFAULT 'unknown',
    "text_language_status" "language_status" NOT NULL DEFAULT 'unknown',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "edition_contents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "covers" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "storage_key" VARCHAR(500) NOT NULL,
    "mime_type" VARCHAR(100) NOT NULL,
    "file_size" BIGINT NOT NULL,
    "width" INTEGER NOT NULL,
    "height" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "covers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "edition_covers" (
    "edition_id" UUID NOT NULL,
    "cover_id" UUID NOT NULL,

    CONSTRAINT "edition_covers_pkey" PRIMARY KEY ("edition_id","cover_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "platforms_name_key" ON "platforms"("name");

-- CreateIndex
CREATE UNIQUE INDEX "platforms_slug_key" ON "platforms"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "regions_name_key" ON "regions"("name");

-- CreateIndex
CREATE UNIQUE INDEX "regions_slug_key" ON "regions"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "rating_systems_name_key" ON "rating_systems"("name");

-- CreateIndex
CREATE UNIQUE INDEX "rating_systems_slug_key" ON "rating_systems"("slug");

-- CreateIndex
CREATE INDEX "region_rating_systems_rating_system_id_idx" ON "region_rating_systems"("rating_system_id");

-- CreateIndex
CREATE UNIQUE INDEX "publishers_name_key" ON "publishers"("name");

-- CreateIndex
CREATE UNIQUE INDEX "publishers_slug_key" ON "publishers"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "languages_code_key" ON "languages"("code");

-- CreateIndex
CREATE UNIQUE INDEX "languages_name_key" ON "languages"("name");

-- CreateIndex
CREATE UNIQUE INDEX "editions_slug_key" ON "editions"("slug");

-- CreateIndex
CREATE INDEX "editions_platform_id_idx" ON "editions"("platform_id");

-- CreateIndex
CREATE INDEX "editions_region_id_rating_system_id_idx" ON "editions"("region_id", "rating_system_id");

-- CreateIndex
CREATE INDEX "editions_publisher_id_idx" ON "editions"("publisher_id");

-- CreateIndex
CREATE INDEX "editions_deleted_at_idx" ON "editions"("deleted_at");

-- CreateIndex
CREATE INDEX "edition_languages_language_id_idx" ON "edition_languages"("language_id");

-- CreateIndex
CREATE INDEX "edition_content_languages_language_id_idx" ON "edition_content_languages"("language_id");

-- CreateIndex
CREATE INDEX "edition_contents_edition_id_idx" ON "edition_contents"("edition_id");

-- CreateIndex
CREATE UNIQUE INDEX "edition_contents_edition_id_position_key" ON "edition_contents"("edition_id", "position");

-- CreateIndex
CREATE UNIQUE INDEX "covers_storage_key_key" ON "covers"("storage_key");

-- CreateIndex
CREATE UNIQUE INDEX "edition_covers_edition_id_key" ON "edition_covers"("edition_id");

-- CreateIndex
CREATE INDEX "edition_covers_cover_id_idx" ON "edition_covers"("cover_id");

-- AddForeignKey
ALTER TABLE "region_rating_systems" ADD CONSTRAINT "region_rating_systems_region_id_fkey" FOREIGN KEY ("region_id") REFERENCES "regions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "region_rating_systems" ADD CONSTRAINT "region_rating_systems_rating_system_id_fkey" FOREIGN KEY ("rating_system_id") REFERENCES "rating_systems"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "editions" ADD CONSTRAINT "editions_platform_id_fkey" FOREIGN KEY ("platform_id") REFERENCES "platforms"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "editions" ADD CONSTRAINT "editions_region_id_rating_system_id_fkey" FOREIGN KEY ("region_id", "rating_system_id") REFERENCES "region_rating_systems"("region_id", "rating_system_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "editions" ADD CONSTRAINT "editions_publisher_id_fkey" FOREIGN KEY ("publisher_id") REFERENCES "publishers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "edition_languages" ADD CONSTRAINT "edition_languages_edition_id_fkey" FOREIGN KEY ("edition_id") REFERENCES "editions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "edition_languages" ADD CONSTRAINT "edition_languages_language_id_fkey" FOREIGN KEY ("language_id") REFERENCES "languages"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "edition_content_languages" ADD CONSTRAINT "edition_content_languages_edition_content_id_fkey" FOREIGN KEY ("edition_content_id") REFERENCES "edition_contents"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "edition_content_languages" ADD CONSTRAINT "edition_content_languages_language_id_fkey" FOREIGN KEY ("language_id") REFERENCES "languages"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "edition_contents" ADD CONSTRAINT "edition_contents_edition_id_fkey" FOREIGN KEY ("edition_id") REFERENCES "editions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "edition_covers" ADD CONSTRAINT "edition_covers_edition_id_fkey" FOREIGN KEY ("edition_id") REFERENCES "editions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "edition_covers" ADD CONSTRAINT "edition_covers_cover_id_fkey" FOREIGN KEY ("cover_id") REFERENCES "covers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Editions

ALTER TABLE "editions"
ADD CONSTRAINT "editions_name_not_empty_check"
CHECK (length(btrim("name")) > 0);

ALTER TABLE "editions"
ADD CONSTRAINT "editions_version_positive_check"
CHECK ("version" >= 1);

-- Active editions must have unique product codes within each region

CREATE UNIQUE INDEX "editions_region_id_product_code_active_key"
ON "editions" ("region_id", "product_code")
WHERE "deleted_at" IS NULL
  AND "product_code" IS NOT NULL;


-- Edition contents

ALTER TABLE "edition_contents"
ADD CONSTRAINT "edition_contents_position_non_negative_check"
CHECK ("position" >= 0);


-- Covers

ALTER TABLE "covers"
ADD CONSTRAINT "covers_file_size_positive_check"
CHECK ("file_size" > 0);

ALTER TABLE "covers"
ADD CONSTRAINT "covers_width_positive_check"
CHECK ("width" > 0);

ALTER TABLE "covers"
ADD CONSTRAINT "covers_height_positive_check"
CHECK ("height" > 0);