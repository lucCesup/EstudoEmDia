import AppKit

let size: CGFloat = 1024
let out = CommandLine.arguments[1]

let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size),
                           bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let rect = NSRect(x: 0, y: 0, width: size, height: size)

// Fundo: degradê diagonal do azul de destaque do app para um índigo profundo.
let top = NSColor(srgbRed: 0.24, green: 0.56, blue: 0.98, alpha: 1)
let bottom = NSColor(srgbRed: 0.16, green: 0.20, blue: 0.62, alpha: 1)
NSGradient(starting: top, ending: bottom)!.draw(in: rect, angle: -60)

func symbol(_ name: String, pointSize: CGFloat, color: NSColor) -> NSImage {
    let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .semibold)
        .applying(.init(paletteColors: [color]))
    return NSImage(systemSymbolName: name, accessibilityDescription: nil)!.withSymbolConfiguration(config)!
}

func draw(_ img: NSImage, center: CGPoint, shadow: Bool) {
    NSGraphicsContext.saveGraphicsState()
    if shadow {
        let s = NSShadow()
        s.shadowColor = NSColor.black.withAlphaComponent(0.25)
        s.shadowBlurRadius = 24
        s.shadowOffset = NSSize(width: 0, height: -12)
        s.set()
    }
    let r = NSRect(x: center.x - img.size.width / 2, y: center.y - img.size.height / 2,
                   width: img.size.width, height: img.size.height)
    img.draw(in: r)
    NSGraphicsContext.restoreGraphicsState()
}

// Livro aberto, branco, levemente abaixo do centro.
let book = symbol("book.fill", pointSize: 430, color: .white)
draw(book, center: CGPoint(x: size / 2, y: size / 2 - 30), shadow: true)

// Badge de notificação: círculo laranja com sino branco, no canto superior direito.
let badgeCenter = CGPoint(x: size * 0.74, y: size * 0.74)
let badgeR: CGFloat = 150
NSGraphicsContext.saveGraphicsState()
let sh = NSShadow()
sh.shadowColor = NSColor.black.withAlphaComponent(0.3)
sh.shadowBlurRadius = 20
sh.shadowOffset = NSSize(width: 0, height: -10)
sh.set()
NSColor(srgbRed: 1.0, green: 0.58, blue: 0.16, alpha: 1).setFill()
NSBezierPath(ovalIn: NSRect(x: badgeCenter.x - badgeR, y: badgeCenter.y - badgeR,
                            width: badgeR * 2, height: badgeR * 2)).fill()
NSGraphicsContext.restoreGraphicsState()
draw(symbol("bell.fill", pointSize: 150, color: .white), center: badgeCenter, shadow: false)

NSGraphicsContext.restoreGraphicsState()
// iOS exige ícone sem transparência: o fundo cobre tudo, então salvamos sem alfa.
let cg = rep.cgImage!
let ctx = CGContext(data: nil, width: Int(size), height: Int(size), bitsPerComponent: 8, bytesPerRow: 0,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!,
                    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
ctx.draw(cg, in: CGRect(x: 0, y: 0, width: size, height: size))
let png = NSBitmapImageRep(cgImage: ctx.makeImage()!).representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: out))
print("ok \(out)")
