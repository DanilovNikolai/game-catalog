import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const platforms = [
  { name: "Sony PlayStation 3", slug: "sony-playstation-3" },
  { name: "Sony PlayStation 4", slug: "sony-playstation-4" },
  { name: "Sony PlayStation 5", slug: "sony-playstation-5" },
  { name: "Nintendo Switch", slug: "nintendo-switch" },
  { name: "Nintendo Switch 2", slug: "nintendo-switch-2" },
  { name: "Microsoft Xbox 360", slug: "microsoft-xbox-360" },
  { name: "Microsoft Xbox One", slug: "microsoft-xbox-one" },
  { name: "Microsoft Xbox Series X", slug: "microsoft-xbox-series-x" },
];

const regions = [
  { name: "North America", slug: "north-america" },
  { name: "Europe", slug: "europe" },
  { name: "Germany", slug: "germany" },
  { name: "Russia", slug: "russia" },
  { name: "United Kingdom", slug: "united-kingdom" },
  { name: "South Korea", slug: "south-korea" },
  { name: "Japan", slug: "japan" },
  { name: "Asia", slug: "asia" },
  { name: "United Arab Emirates", slug: "united-arab-emirates" },
  { name: "Australia", slug: "australia" },
  { name: "Brazil", slug: "brazil" },
  { name: "Worldwide", slug: "worldwide" },
  { name: "Unknown", slug: "unknown" },
];

const ratingSystems = [
  { name: "ESRB", slug: "esrb" },
  { name: "PEGI", slug: "pegi" },
  { name: "USK", slug: "usk" },
  { name: "CERO", slug: "cero" },
  { name: "GRAC", slug: "grac" },
  { name: "ACB", slug: "acb" },
  { name: "ClassInd", slug: "classind" },
  { name: "NMA", slug: "nma" },
  { name: "RARS", slug: "rars" },
  { name: "BBFC", slug: "bbfc" },
  { name: "Unknown", slug: "unknown" },
];

const languages = [
  { code: "en", name: "English" },
  { code: "de", name: "German" },
  { code: "ru", name: "Russian" },
  { code: "pt-BR", name: "Portuguese (Brazil)" },
  { code: "pt-PT", name: "Portuguese (Portugal)" },
  { code: "zh-Hans", name: "Chinese (Simplified)" },
  { code: "zh-Hant", name: "Chinese (Traditional)" },
  { code: "es-ES", name: "Spanish (Spain)" },
  { code: "es-419", name: "Spanish (Latin America)" },
];

// Region -> allowed rating systems
const regionRatingMappings = [
  { region: "north-america", ratings: ["esrb"] },
  { region: "europe", ratings: ["pegi"] },
  { region: "germany", ratings: ["usk"] },
  { region: "russia", ratings: ["rars", "pegi"] },
  { region: "united-kingdom", ratings: ["pegi", "bbfc"] },
  { region: "south-korea", ratings: ["grac"] },
  { region: "japan", ratings: ["cero"] },
  { region: "asia", ratings: ["unknown"] },
  { region: "united-arab-emirates", ratings: ["nma"] },
  { region: "australia", ratings: ["acb"] },
  { region: "brazil", ratings: ["classind"] },
  { region: "worldwide", ratings: ["unknown"] },
  { region: "unknown", ratings: ["unknown"] },
];

async function main() {
  // Platforms
  for (const platform of platforms) {
    await prisma.platform.upsert({
      where: { slug: platform.slug },
      update: { name: platform.name, isActive: true },
      create: platform,
    });
  }

  // Regions
  for (const region of regions) {
    await prisma.region.upsert({
      where: { slug: region.slug },
      update: { name: region.name, isActive: true },
      create: region,
    });
  }

  // Rating systems
  for (const rating of ratingSystems) {
    await prisma.ratingSystem.upsert({
      where: { slug: rating.slug },
      update: { name: rating.name, isActive: true },
      create: rating,
    });
  }

  // Languages
  for (const language of languages) {
    await prisma.language.upsert({
      where: { code: language.code },
      update: { name: language.name, isActive: true },
      create: language,
    });
  }

  // Region-rating system relations
  for (const mapping of regionRatingMappings) {
    const region = await prisma.region.findUniqueOrThrow({
      where: { slug: mapping.region },
    });

    for (const ratingSlug of mapping.ratings) {
      const rating = await prisma.ratingSystem.findUniqueOrThrow({
        where: { slug: ratingSlug },
      });

      await prisma.regionRatingSystem.upsert({
        where: {
          regionId_ratingSystemId: {
            regionId: region.id,
            ratingSystemId: rating.id,
          },
        },
        update: {},
        create: {
          regionId: region.id,
          ratingSystemId: rating.id,
        },
      });
    }
  }

  console.log("Seed completed successfully.");
}

main()
  .catch((error) => {
    console.error("Seed failed:", error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
