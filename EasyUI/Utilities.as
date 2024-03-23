bool isMouseInBounds(Vec2f &in min, Vec2f &in max)
{
    if (!isClient()) return false;

    Vec2f mousePos = getControls().getInterpMouseScreenPos();
    return (
        mousePos.x >= min.x && mousePos.x <= max.x &&
        mousePos.y >= min.y && mousePos.y <= max.y
    );
}

bool isHovering(Component@ component)
{
    Vec2f min = component.getTruePosition();
    Vec2f max = min + component.getTrueBounds();
    return isMouseInBounds(min, max);
}

// For a list of sizes, determine which sizes exceed their minimum
// size and distribute the excess to the other sizes. If all
// excess has been distributed or if the minimum sizes make it
// impossible to distribute the excess, terminate the recursion.
float[] distributeExcess(float[] sizes, float[] minSizes)
{
    uint count = sizes.size();
    float sizesSum = 0.0f;

    // Accumulate excess size that needs redistributing
    float excess = 0.0f;
    uint excessCount = 0;

    for (uint i = 0; i < count; i++)
    {
        float size = sizes[i];
        float minSize = minSizes[i];

        if (minSize >= size)
        {
            excess += minSize - size;
            excessCount++;
            sizes[i] = minSize;
        }
        else
        {
            sizesSum += size;
        }
    }

    // All excess has been distributed or all sizes have excess
    if (excess == 0.0f || excessCount == count)
    {
        return sizes;
    }

    // Redistribute excess size
    for (uint i = 0; i < count; i++)
    {
        float size = sizes[i];
        float minSize = minSizes[i];

        if (minSize < size)
        {
            sizes[i] -= excess * size / sizesSum;
        }
    }

    // Recurse
    return distributeExcess(sizes, minSizes);
}

// Calculate the height of text that wraps at the specified width
// Implemented using my best assumption rather than using Irrlicht code as reference
float calculateTextHeight(string text, string font, float width, string[] &inout lines)
{
    // print("Width: " + width);

    uint index = 0;
    bool firstWord = true;

    // Skip spaces before the first word
    while (text.substr(index, 1) == " ")
    {
        index++;
    }

    GUI::SetFont(font);

    while (true) // o_O
    {
        // Get a substring with an increasing number of words
        uint nextIndex = text.find(" ", index + 1);
        string substr = text.substr(0, nextIndex);

        // Get substring dimensions
        Vec2f dim;
        GUI::GetTextDimensions(substr, dim);

        // Substring exceeds width so it must wrap
        if (dim.x > width)
        {
            // print("Substring '" + substr + "' is too long");

            if (firstWord)
            {
                index = nextIndex;
            }

            // Skip spaces after the last word
            while (text.substr(index, 1) == " ")
            {
                index++;
            }

            // Recursively wrap text following the substring
            string rest = text.substr(index);
            if (rest != "")
            {
                string prev = text.substr(0, index);
                lines.push_back(prev);
                // print("Added '" + prev + "' to lines array");

                // print("Recursing '" + rest + "'");
                return dim.y + calculateTextHeight(rest, font, width, lines);
            }
            else
            {
                return dim.y;
            }
        }
        // Reached the end of the text without exceeding the width
        else if (nextIndex == -1)
        {
            lines.push_back(substr);
            // print("Added '" + substr + "' to lines array");

            // print("Substring '" + substr + "' is the entire text");
            return dim.y;
        }

        // print("Substring '" + substr + "' is too short");

        // Substring is yet to exceed width, so remember index and continue
        index = nextIndex;
        firstWord = false;
    }

    // Impossible path
    return 0.0f;
}

namespace GUI
{
    void DrawOutlinedRectangle(Vec2f min, Vec2f max, float thickness, SColor color)
    {
        float minX = Maths::Min(min.x, max.x);
        float minY = Maths::Min(min.y, max.y);
        float maxY = Maths::Max(min.y, max.y);
        float maxX = Maths::Max(min.x, max.x);

        GUI::DrawRectangle(min, Vec2f(minX + thickness, maxY), color); // Left
        GUI::DrawRectangle(min, Vec2f(maxX, minY + thickness), color); // Top
        GUI::DrawRectangle(Vec2f(maxX - thickness, minY), max, color); // Right
        GUI::DrawRectangle(Vec2f(minX, maxY - thickness), max, color); // Bottom
    }
}
