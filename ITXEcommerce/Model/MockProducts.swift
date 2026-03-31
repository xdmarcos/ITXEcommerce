//
//  MockProducts.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

@MainActor
extension Product {
    static let mockProducts: [Product] = [
        Product(
            productId: "TRS-001",
            name: "Slim Chino Trousers",
            brand: "Zara",
            productDescription: "Classic slim-fit chino trousers crafted from lightweight stretch cotton. Perfect for smart-casual occasions.",
            category: .trousers,
            price: 39.95,
            variants: [
                ProductVariant(id: "TRS-001-BEI", colorName: "Beige", colorHex: "#D4B896",
                               imageURLs: ["https://picsum.photos/seed/trs001bei1/400/600",
                                           "https://picsum.photos/seed/trs001bei2/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl]),
                ProductVariant(id: "TRS-001-NAV", colorName: "Navy", colorHex: "#1B2A4A",
                               imageURLs: ["https://picsum.photos/seed/trs001nav1/400/600"],
                               availableSizes: [.s, .m, .l, .xl, .xxl])
            ]
        ),
        Product(
            productId: "TRS-002",
            name: "Wide-Leg Linen Trousers",
            brand: "Massimo Dutti",
            productDescription: "Relaxed wide-leg cut in breathable pure linen. Features a high waist and side pockets for effortless style.",
            category: .trousers,
            price: 59.95,
            variants: [
                ProductVariant(id: "TRS-002-WHT", colorName: "White", colorHex: "#F5F5F0",
                               imageURLs: ["https://picsum.photos/seed/trs002wht1/400/600",
                                           "https://picsum.photos/seed/trs002wht2/400/600"],
                               availableSizes: [.xxs, .xs, .s, .m, .l]),
                ProductVariant(id: "TRS-002-OLV", colorName: "Olive", colorHex: "#6B6B3A",
                               imageURLs: ["https://picsum.photos/seed/trs002olv1/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl])
            ]
        ),
        Product(
            productId: "TRS-003",
            name: "Tailored Jogger Trousers",
            brand: "Pull&Bear",
            productDescription: "Smart jogger silhouette with elasticated waist and tapered leg. Made from a soft twill fabric blend.",
            category: .trousers,
            price: 29.99,
            variants: [
                ProductVariant(id: "TRS-003-GRY", colorName: "Grey", colorHex: "#9E9E9E",
                               imageURLs: ["https://picsum.photos/seed/trs003gry1/400/600"],
                               availableSizes: [.s, .m, .l, .xl]),
                ProductVariant(id: "TRS-003-BLK", colorName: "Black", colorHex: "#1A1A1A",
                               imageURLs: ["https://picsum.photos/seed/trs003blk1/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl, .xxl])
            ]
        ),
        Product(
            productId: "DNM-001",
            name: "Straight-Fit Jeans",
            brand: "Zara",
            productDescription: "Classic straight-fit jeans in rigid denim. Five-pocket styling with a mid-rise waistband.",
            category: .denim,
            price: 45.95,
            variants: [
                ProductVariant(id: "DNM-001-MBL", colorName: "Mid Blue", colorHex: "#4A7AB5",
                               imageURLs: ["https://picsum.photos/seed/dnm001mbl1/400/600",
                                           "https://picsum.photos/seed/dnm001mbl2/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl]),
                ProductVariant(id: "DNM-001-DBL", colorName: "Dark Blue", colorHex: "#1C3A6E",
                               imageURLs: ["https://picsum.photos/seed/dnm001dbl1/400/600"],
                               availableSizes: [.s, .m, .l, .xl, .xxl])
            ]
        ),
        Product(
            productId: "DNM-002",
            name: "Skinny Ripped Jeans",
            brand: "Bershka",
            productDescription: "Skinny-fit jeans with distressed knee detailing and a low-rise cut. A wardrobe essential for an edgy look.",
            category: .denim,
            price: 35.99,
            variants: [
                ProductVariant(id: "DNM-002-LBL", colorName: "Light Blue", colorHex: "#89B4D9",
                               imageURLs: ["https://picsum.photos/seed/dnm002lbl1/400/600"],
                               availableSizes: [.xxs, .xs, .s, .m, .l]),
                ProductVariant(id: "DNM-002-BLK", colorName: "Black", colorHex: "#1A1A1A",
                               imageURLs: ["https://picsum.photos/seed/dnm002blk1/400/600"],
                               availableSizes: [.xs, .s, .m, .l])
            ]
        ),
        Product(
            productId: "DNM-003",
            name: "Wide-Leg Vintage Jeans",
            brand: "Stradivarius",
            productDescription: "90s-inspired wide-leg jeans with a high-rise fit and subtle fade wash. Cut from heavyweight denim.",
            category: .denim,
            price: 49.95,
            variants: [
                ProductVariant(id: "DNM-003-ICE", colorName: "Ice Wash", colorHex: "#C8DCF0",
                               imageURLs: ["https://picsum.photos/seed/dnm003ice1/400/600",
                                           "https://picsum.photos/seed/dnm003ice2/400/600"],
                               availableSizes: [.xxs, .xs, .s, .m]),
                ProductVariant(id: "DNM-003-MBL", colorName: "Mid Blue", colorHex: "#4A7AB5",
                               imageURLs: ["https://picsum.photos/seed/dnm003mbl1/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl])
            ]
        ),
        Product(
            productId: "HOD-001",
            name: "Oversized Fleece Hoodie",
            brand: "Zara",
            productDescription: "Ultra-soft fleece hoodie in an oversized drop-shoulder fit. Features a kangaroo pocket and adjustable drawstring hood.",
            category: .hoodies,
            price: 49.95,
            variants: [
                ProductVariant(id: "HOD-001-CRM", colorName: "Cream", colorHex: "#F2EFE4",
                               imageURLs: ["https://picsum.photos/seed/hod001crm1/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl, .xxl]),
                ProductVariant(id: "HOD-001-MST", colorName: "Mustard", colorHex: "#D4A017",
                               imageURLs: ["https://picsum.photos/seed/hod001mst1/400/600"],
                               availableSizes: [.s, .m, .l, .xl])
            ]
        ),
        Product(
            productId: "HOD-002",
            name: "Zip-Up Tech Hoodie",
            brand: "Massimo Dutti",
            productDescription: "Full-zip hoodie made from moisture-wicking technical fabric. Slim fit with two side zip pockets.",
            category: .hoodies,
            price: 79.95,
            variants: [
                ProductVariant(id: "HOD-002-NVY", colorName: "Navy", colorHex: "#1B2A4A",
                               imageURLs: ["https://picsum.photos/seed/hod002nvy1/400/600",
                                           "https://picsum.photos/seed/hod002nvy2/400/600"],
                               availableSizes: [.s, .m, .l, .xl, .xxl]),
                ProductVariant(id: "HOD-002-CHR", colorName: "Charcoal", colorHex: "#3C3C3C",
                               imageURLs: ["https://picsum.photos/seed/hod002chr1/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl])
            ]
        ),
        Product(
            productId: "HOD-003",
            name: "Cropped Graphic Hoodie",
            brand: "Bershka",
            productDescription: "Cropped hoodie with bold front graphic print. Relaxed fit in brushed cotton-blend fleece.",
            category: .hoodies,
            price: 32.99,
            variants: [
                ProductVariant(id: "HOD-003-BLK", colorName: "Black", colorHex: "#1A1A1A",
                               imageURLs: ["https://picsum.photos/seed/hod003blk1/400/600"],
                               availableSizes: [.xxs, .xs, .s, .m, .l]),
                ProductVariant(id: "HOD-003-LAV", colorName: "Lavender", colorHex: "#BBA8D4",
                               imageURLs: ["https://picsum.photos/seed/hod003lav1/400/600"],
                               availableSizes: [.xxs, .xs, .s, .m])
            ]
        ),
        Product(
            productId: "JKT-001",
            name: "Leather Biker Jacket",
            brand: "Zara",
            productDescription: "Classic asymmetric biker jacket in smooth faux leather. Features zip pockets, belted waist, and quilted lining.",
            category: .jacket,
            price: 129.00,
            variants: [
                ProductVariant(id: "JKT-001-BLK", colorName: "Black", colorHex: "#1A1A1A",
                               imageURLs: ["https://picsum.photos/seed/jkt001blk1/400/600",
                                           "https://picsum.photos/seed/jkt001blk2/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl]),
                ProductVariant(id: "JKT-001-TAN", colorName: "Tan", colorHex: "#C4873A",
                               imageURLs: ["https://picsum.photos/seed/jkt001tan1/400/600"],
                               availableSizes: [.s, .m, .l, .xl])
            ]
        ),
        Product(
            productId: "JKT-002",
            name: "Quilted Puffer Jacket",
            brand: "Pull&Bear",
            productDescription: "Lightweight quilted jacket with channel stitching and a recycled insulation filling. Packable into its own pocket.",
            category: .jacket,
            price: 69.99,
            variants: [
                ProductVariant(id: "JKT-002-OLV", colorName: "Olive", colorHex: "#6B6B3A",
                               imageURLs: ["https://picsum.photos/seed/jkt002olv1/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl, .xxl]),
                ProductVariant(id: "JKT-002-BRG", colorName: "Burgundy", colorHex: "#7B1F3A",
                               imageURLs: ["https://picsum.photos/seed/jkt002brg1/400/600"],
                               availableSizes: [.xs, .s, .m, .l])
            ]
        ),
        Product(
            productId: "JKT-003",
            name: "Structured Blazer Jacket",
            brand: "Massimo Dutti",
            productDescription: "Tailored single-breasted blazer in stretch wool blend. Notch lapels, two-button closure, and flap pockets.",
            category: .jacket,
            price: 149.00,
            variants: [
                ProductVariant(id: "JKT-003-CML", colorName: "Camel", colorHex: "#C19A6B",
                               imageURLs: ["https://picsum.photos/seed/jkt003cml1/400/600",
                                           "https://picsum.photos/seed/jkt003cml2/400/600"],
                               availableSizes: [.xxs, .xs, .s, .m, .l]),
                ProductVariant(id: "JKT-003-NVY", colorName: "Navy", colorHex: "#1B2A4A",
                               imageURLs: ["https://picsum.photos/seed/jkt003nvy1/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl])
            ]
        ),
        Product(
            productId: "SHT-001",
            name: "Oversized Oxford Shirt",
            brand: "Zara",
            productDescription: "Relaxed oversized fit in washed Oxford cotton. Chest patch pocket and a curved hemline.",
            category: .shirt,
            price: 35.95,
            variants: [
                ProductVariant(id: "SHT-001-WHT", colorName: "White", colorHex: "#F5F5F0",
                               imageURLs: ["https://picsum.photos/seed/sht001wht1/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl, .xxl]),
                ProductVariant(id: "SHT-001-STP", colorName: "Blue Stripe", colorHex: "#6A9DC8",
                               imageURLs: ["https://picsum.photos/seed/sht001stp1/400/600"],
                               availableSizes: [.s, .m, .l, .xl])
            ]
        ),
        Product(
            productId: "SHT-002",
            name: "Slim Flannel Check Shirt",
            brand: "Massimo Dutti",
            productDescription: "Slim-fit shirt in soft brushed flannel with an all-over check pattern. Button-down collar and single-button cuffs.",
            category: .shirt,
            price: 55.00,
            variants: [
                ProductVariant(id: "SHT-002-GRN", colorName: "Green Check", colorHex: "#4A7A4A",
                               imageURLs: ["https://picsum.photos/seed/sht002grn1/400/600",
                                           "https://picsum.photos/seed/sht002grn2/400/600"],
                               availableSizes: [.s, .m, .l, .xl]),
                ProductVariant(id: "SHT-002-RED", colorName: "Red Check", colorHex: "#A83232",
                               imageURLs: ["https://picsum.photos/seed/sht002red1/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl, .xxl])
            ]
        ),
        Product(
            productId: "SHT-003",
            name: "Linen Resort Shirt",
            brand: "Stradivarius",
            productDescription: "Breezy short-sleeve shirt in 100% linen. Camp collar, relaxed fit, and a straight hem.",
            category: .shirt,
            price: 29.99,
            variants: [
                ProductVariant(id: "SHT-003-TER", colorName: "Terracotta", colorHex: "#C1603A",
                               imageURLs: ["https://picsum.photos/seed/sht003ter1/400/600"],
                               availableSizes: [.xxs, .xs, .s, .m, .l]),
                ProductVariant(id: "SHT-003-SAG", colorName: "Sage", colorHex: "#87A878",
                               imageURLs: ["https://picsum.photos/seed/sht003sag1/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl])
            ]
        ),
        Product(
            productId: "SHO-001",
            name: "Leather Chunky Sneakers",
            brand: "Zara",
            productDescription: "Retro-inspired dad sneakers in smooth leather upper. Thick EVA sole with contrast stitching detailing.",
            category: .shoes,
            price: 89.95,
            variants: [
                ProductVariant(id: "SHO-001-WHT", colorName: "White", colorHex: "#F5F5F0",
                               imageURLs: ["https://picsum.photos/seed/sho001wht1/400/600",
                                           "https://picsum.photos/seed/sho001wht2/400/600"],
                               availableSizes: [.s, .m, .l, .xl]),
                ProductVariant(id: "SHO-001-BLK", colorName: "Black", colorHex: "#1A1A1A",
                               imageURLs: ["https://picsum.photos/seed/sho001blk1/400/600"],
                               availableSizes: [.s, .m, .l, .xl, .xxl])
            ]
        ),
        Product(
            productId: "SHO-002",
            name: "Suede Chelsea Boots",
            brand: "Massimo Dutti",
            productDescription: "Pull-on Chelsea boots in premium split suede. Elasticated gussets, stacked heel, and leather lining.",
            category: .shoes,
            price: 119.00,
            variants: [
                ProductVariant(id: "SHO-002-TAN", colorName: "Tan", colorHex: "#C4873A",
                               imageURLs: ["https://picsum.photos/seed/sho002tan1/400/600"],
                               availableSizes: [.s, .m, .l, .xl]),
                ProductVariant(id: "SHO-002-CHR", colorName: "Charcoal", colorHex: "#3C3C3C",
                               imageURLs: ["https://picsum.photos/seed/sho002chr1/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl, .xxl])
            ]
        ),
        Product(
            productId: "SHO-003",
            name: "Canvas Espadrille Loafers",
            brand: "Stradivarius",
            productDescription: "Slip-on loafers with a jute rope sole and canvas upper. A warm-weather staple with a relaxed silhouette.",
            category: .shoes,
            price: 39.99,
            variants: [
                ProductVariant(id: "SHO-003-NVY", colorName: "Navy", colorHex: "#1B2A4A",
                               imageURLs: ["https://picsum.photos/seed/sho003nvy1/400/600"],
                               availableSizes: [.xxs, .xs, .s, .m, .l]),
                ProductVariant(id: "SHO-003-ECR", colorName: "Ecru", colorHex: "#EDE8D9",
                               imageURLs: ["https://picsum.photos/seed/sho003ecr1/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl])
            ]
        ),
        Product(
            productId: "ACC-001",
            name: "Ribbed Knit Beanie",
            brand: "Zara",
            productDescription: "Soft ribbed-knit beanie in a wool-blend yarn. Slouchy fit with a fold-over cuff.",
            category: .accessories,
            price: 19.95,
            variants: [
                ProductVariant(id: "ACC-001-CRM", colorName: "Cream", colorHex: "#F2EFE4",
                               imageURLs: ["https://picsum.photos/seed/acc001crm1/400/600"],
                               availableSizes: [.s, .m, .l]),
                ProductVariant(id: "ACC-001-BLK", colorName: "Black", colorHex: "#1A1A1A",
                               imageURLs: ["https://picsum.photos/seed/acc001blk1/400/600"],
                               availableSizes: [.s, .m, .l]),
                ProductVariant(id: "ACC-001-CAM", colorName: "Camel", colorHex: "#C19A6B",
                               imageURLs: ["https://picsum.photos/seed/acc001cam1/400/600"],
                               availableSizes: [.s, .m, .l])
            ]
        ),
        Product(
            productId: "ACC-002",
            name: "Leather Belt",
            brand: "Massimo Dutti",
            productDescription: "Full-grain leather belt with a brushed silver pin buckle. Slim 3 cm width, available in multiple lengths.",
            category: .accessories,
            price: 45.00,
            variants: [
                ProductVariant(id: "ACC-002-BRW", colorName: "Brown", colorHex: "#6B3A2A",
                               imageURLs: ["https://picsum.photos/seed/acc002brw1/400/600"],
                               availableSizes: [.s, .m, .l, .xl]),
                ProductVariant(id: "ACC-002-BLK", colorName: "Black", colorHex: "#1A1A1A",
                               imageURLs: ["https://picsum.photos/seed/acc002blk1/400/600"],
                               availableSizes: [.s, .m, .l, .xl, .xxl])
            ]
        ),
        Product(
            productId: "TRS-004",
            name: "Cargo Utility Trousers",
            brand: "Pull&Bear",
            productDescription: "Relaxed-fit cargo trousers with multiple utility pockets and an elasticated waistband. Built from durable ripstop cotton.",
            category: .trousers,
            price: 45.99,
            variants: [
                ProductVariant(id: "TRS-004-KHK", colorName: "Khaki", colorHex: "#8B7D5E",
                               imageURLs: ["https://picsum.photos/seed/trs004khk1/400/600",
                                           "https://picsum.photos/seed/trs004khk2/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl, .xxl]),
                ProductVariant(id: "TRS-004-BLK", colorName: "Black", colorHex: "#1A1A1A",
                               imageURLs: ["https://picsum.photos/seed/trs004blk1/400/600"],
                               availableSizes: [.s, .m, .l, .xl])
            ]
        ),
        Product(
            productId: "DNM-004",
            name: "Slim Tapered Jeans",
            brand: "Massimo Dutti",
            productDescription: "Slim-tapered jeans in comfort-stretch selvedge denim. Clean finish with minimal detailing for a refined everyday look.",
            category: .denim,
            price: 69.00,
            variants: [
                ProductVariant(id: "DNM-004-IND", colorName: "Indigo", colorHex: "#3D5A8A",
                               imageURLs: ["https://picsum.photos/seed/dnm004ind1/400/600",
                                           "https://picsum.photos/seed/dnm004ind2/400/600"],
                               availableSizes: [.s, .m, .l, .xl]),
                ProductVariant(id: "DNM-004-BLK", colorName: "Black", colorHex: "#1A1A1A",
                               imageURLs: ["https://picsum.photos/seed/dnm004blk1/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl, .xxl])
            ]
        ),
        Product(
            productId: "HOD-004",
            name: "Washed Pullover Hoodie",
            brand: "Stradivarius",
            productDescription: "Garment-washed pullover hoodie for a lived-in feel. Dropped shoulders, ribbed cuffs, and a tonal embroidered logo.",
            category: .hoodies,
            price: 37.99,
            variants: [
                ProductVariant(id: "HOD-004-SKB", colorName: "Sky Blue", colorHex: "#7AB8D4",
                               imageURLs: ["https://picsum.photos/seed/hod004skb1/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl]),
                ProductVariant(id: "HOD-004-SND", colorName: "Sand", colorHex: "#D4C5A5",
                               imageURLs: ["https://picsum.photos/seed/hod004snd1/400/600"],
                               availableSizes: [.xxs, .xs, .s, .m, .l])
            ]
        ),
        Product(
            productId: "JKT-004",
            name: "Denim Trucker Jacket",
            brand: "Bershka",
            productDescription: "Classic trucker jacket in rigid denim with contrast stitching. Button-front closure, chest pockets, and adjustable side tabs.",
            category: .jacket,
            price: 59.99,
            variants: [
                ProductVariant(id: "JKT-004-MBL", colorName: "Mid Blue", colorHex: "#4A7AB5",
                               imageURLs: ["https://picsum.photos/seed/jkt004mbl1/400/600",
                                           "https://picsum.photos/seed/jkt004mbl2/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl]),
                ProductVariant(id: "JKT-004-BLK", colorName: "Black", colorHex: "#1A1A1A",
                               imageURLs: ["https://picsum.photos/seed/jkt004blk1/400/600"],
                               availableSizes: [.s, .m, .l, .xl, .xxl])
            ]
        ),
        Product(
            productId: "SHT-004",
            name: "Poplin Utility Shirt",
            brand: "Zara",
            productDescription: "Boxy-fit shirt in crisp cotton poplin with patch pockets and a buttoned flap. Versatile enough to wear tucked or untucked.",
            category: .shirt,
            price: 32.95,
            variants: [
                ProductVariant(id: "SHT-004-WHT", colorName: "White", colorHex: "#F5F5F0",
                               imageURLs: ["https://picsum.photos/seed/sht004wht1/400/600"],
                               availableSizes: [.xs, .s, .m, .l, .xl, .xxl]),
                ProductVariant(id: "SHT-004-ECR", colorName: "Ecru", colorHex: "#EDE8D9",
                               imageURLs: ["https://picsum.photos/seed/sht004ecr1/400/600"],
                               availableSizes: [.xs, .s, .m, .l])
            ]
        ),
        Product(
            productId: "SHO-004",
            name: "Leather Derby Shoes",
            brand: "Massimo Dutti",
            productDescription: "Cap-toe derby shoes crafted from full-grain calf leather. Leather lining, rubber sole, and Goodyear-welted construction.",
            category: .shoes,
            price: 149.00,
            variants: [
                ProductVariant(id: "SHO-004-BLK", colorName: "Black", colorHex: "#1A1A1A",
                               imageURLs: ["https://picsum.photos/seed/sho004blk1/400/600",
                                           "https://picsum.photos/seed/sho004blk2/400/600"],
                               availableSizes: [.s, .m, .l, .xl]),
                ProductVariant(id: "SHO-004-BRW", colorName: "Dark Brown", colorHex: "#4A2C1A",
                               imageURLs: ["https://picsum.photos/seed/sho004brw1/400/600"],
                               availableSizes: [.s, .m, .l, .xl, .xxl])
            ]
        ),
        Product(
            productId: "ACC-003",
            name: "Woven Bucket Hat",
            brand: "Stradivarius",
            productDescription: "Structured bucket hat in a woven cotton-blend fabric. Features a grosgrain inner band and a medium brim.",
            category: .accessories,
            price: 22.99,
            variants: [
                ProductVariant(id: "ACC-003-ECR", colorName: "Ecru", colorHex: "#EDE8D9",
                               imageURLs: ["https://picsum.photos/seed/acc003ecr1/400/600"],
                               availableSizes: [.s, .m, .l]),
                ProductVariant(id: "ACC-003-KHK", colorName: "Khaki", colorHex: "#8B7D5E",
                               imageURLs: ["https://picsum.photos/seed/acc003khk1/400/600"],
                               availableSizes: [.s, .m, .l])
            ]
        ),
        Product(
            productId: "ACC-004",
            name: "Merino Wool Scarf",
            brand: "Massimo Dutti",
            productDescription: "Lightweight scarf in 100% extra-fine merino wool. Generous width for wrapping and a fringed hem on both ends.",
            category: .accessories,
            price: 59.00,
            variants: [
                ProductVariant(id: "ACC-004-CAM", colorName: "Camel", colorHex: "#C19A6B",
                               imageURLs: ["https://picsum.photos/seed/acc004cam1/400/600"],
                               availableSizes: [.s, .m, .l]),
                ProductVariant(id: "ACC-004-CHR", colorName: "Charcoal", colorHex: "#3C3C3C",
                               imageURLs: ["https://picsum.photos/seed/acc004chr1/400/600"],
                               availableSizes: [.s, .m, .l]),
                ProductVariant(id: "ACC-004-BRG", colorName: "Burgundy", colorHex: "#7B1F3A",
                               imageURLs: ["https://picsum.photos/seed/acc004brg1/400/600"],
                               availableSizes: [.s, .m, .l])
            ]
        ),
        Product(
            productId: "ACC-005",
            name: "Canvas Tote Bag",
            brand: "Zara",
            productDescription: "Oversized tote in heavy-duty canvas with reinforced handles and an internal zip pocket. A sustainable everyday carry.",
            category: .accessories,
            price: 29.95,
            variants: [
                ProductVariant(id: "ACC-005-NTR", colorName: "Natural", colorHex: "#D9CEB2",
                               imageURLs: ["https://picsum.photos/seed/acc005ntr1/400/600",
                                           "https://picsum.photos/seed/acc005ntr2/400/600"],
                               availableSizes: [.s, .m, .l]),
                ProductVariant(id: "ACC-005-BLK", colorName: "Black", colorHex: "#1A1A1A",
                               imageURLs: ["https://picsum.photos/seed/acc005blk1/400/600"],
                               availableSizes: [.s, .m, .l])
            ]
        )
    ]
}
