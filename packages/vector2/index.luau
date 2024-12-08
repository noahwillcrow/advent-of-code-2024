export type Vector2 = { x: number, y: number }

function new(x: number, y: number): Vector2
    return { x = x, y = y }
end

function add(v1: Vector2, v2: Vector2): Vector2
    return { x = v1.x + v2.x, y = v1.y + v2.y }
end

function sub(v1: Vector2, v2: Vector2): Vector2
    return { x = v1.x - v2.x, y = v1.y - v2.y }
end

function mul(v: Vector2, scalar: number): Vector2
    return { x = v.x * scalar, y = v.y * scalar }
end

function div(v: Vector2, scalar: number): Vector2
    return { x = v.x / scalar, y = v.y / scalar }
end

function eq(v1: Vector2, v2: Vector2): boolean
    return v1.x == v2.x and v1.y == v2.y
end

function dot(v1: Vector2, v2: Vector2): number
    return v1.x * v2.x + v1.y * v2.y
end

function cross(v1: Vector2, v2: Vector2): number
    return v1.x * v2.y - v1.y * v2.x
end

function magnitude(v: Vector2): number
    return math.sqrt(v.x * v.x + v.y * v.y)
end

function magnitudeSquared(v: Vector2): number
    return v.x * v.x + v.y * v.y
end

function unit(v: Vector2): Vector2
    return div(v, magnitude(v))
end

function rotate(v: Vector2, angle: number): Vector2
    local cos = math.cos(angle)
    local sin = math.sin(angle)
    return {
        x = v.x * cos - v.y * sin,
        y = v.x * sin + v.y * cos
    }
end

function angle(v1: Vector2, v2: Vector2): number
    return math.atan2(v2.y, v2.x) - math.atan2(v1.y, v1.x)
end

return {
    new = new,
    add = add,
    sub = sub,
    mul = mul,
    div = div,
    eq = eq,
    dot = dot,
    cross = cross,
    magnitude = magnitude,
    magnitudeSquared = magnitudeSquared,
    unit = unit,
    rotate = rotate,
    angle = angle
}
