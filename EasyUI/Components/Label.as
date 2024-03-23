interface Label : Stack
{
    void SetText(string text);
    string getText();

    void SetFont(string font);
    string getFont();

    void SetColor(SColor color);
    SColor getColor();

    void SetWrap(bool wrap);
    bool getWrap();

    void SetMaxLines(uint lines);
    uint getMaxLines();
}

class StandardLabel : Label, StandardStack
{
    private string text = "";
    private string font = "menu";
    private SColor color = color_white;
    private bool wrap = false;
    private uint maxLines = 0;

    private string[] lines;
    private float fontHeight = 0.0f;
    private Vec2f textDim = Vec2f_zero;

    StandardLabel()
    {
        super();

        UpdateFontHeight();
    }

    private void UpdateFontHeight()
    {
        Vec2f dim;
        GUI::SetFont(font);
        GUI::GetTextDimensions("", dim);
        fontHeight = dim.y;
    }

    void SetText(string text)
    {
        if (this.text == text) return;

        this.text = text;

        DispatchEvent(Event::Text);
        CalculateMinBounds();
    }

    string getText()
    {
        return text;
    }

    void SetFont(string font)
    {
        if (this.font == font) return;

        this.font = font;

        DispatchEvent(Event::Font);
        UpdateFontHeight();
        CalculateMinBounds();
    }

    string getFont()
    {
        return font;
    }

    void SetColor(SColor color)
    {
        if (this.color == color) return;

        this.color = color;

        DispatchEvent(Event::Color);
    }

    SColor getColor()
    {
        return color;
    }

    void SetWrap(bool wrap)
    {
        if (this.wrap == wrap) return;

        this.wrap = wrap;

        DispatchEvent(Event::Wrap);
    }

    bool getWrap()
    {
        return wrap;
    }

    void SetMaxLines(uint maxLines)
    {
        if (this.maxLines == maxLines) return;

        this.maxLines = maxLines;

        DispatchEvent(Event::MaxLines);
    }

    uint getMaxLines()
    {
        return maxLines;
    }

    // Calculate the height of text that wraps at the specified width
    // Implemented using my best assumption rather than using Irrlicht code as reference
    private Vec2f calculateWrappedTextDimensions(string text, float wrapWidth, string[] &inout lines)
    {
        // print("Wrap width: " + wrapWidth);

        uint index = 0;
        bool firstWord = true;

        // Skip spaces before the first word
        while (text.substr(index, 1) == " ")
        {
            index++;
        }

        while (true) // o_O
        {
            // Get a substring with an increasing number of words
            uint nextIndex = text.find(" ", index + 1);
            string substr = text.substr(0, nextIndex);
            bool lastLine = maxLines > 0 && lines.size() == maxLines - 1;

            if (lastLine)
            {
                substr += " ...";
            }

            // Get substring dimensions
            Vec2f dim;
            GUI::GetTextDimensions(substr, dim);

            // Substring exceeds wrap width so it must wrap
            if (dim.x > wrapWidth)
            {
                // print("Substring '" + substr + "' is too long");

                if (firstWord)
                {
                    index = nextIndex;
                }

                string prev = text.substr(0, index);
                if (lastLine)
                {
                    prev += " ...";
                }

                Vec2f prevDim;
                GUI::GetTextDimensions(prev, prevDim);

                // Skip spaces after the last word
                while (text.substr(index, 1) == " ")
                {
                    index++;
                }

                // Recursively wrap text following the substring
                string rest = text.substr(index);
                if (rest != "")
                {
                    lines.push_back(prev);
                    // print("Added '" + prev + "' to lines array");

                    if (lastLine)
                    {
                        return prevDim;
                    }

                    // print("Recursing '" + rest + "'");
                    Vec2f restDim = calculateWrappedTextDimensions(rest, wrapWidth, lines);
                    return Vec2f(Maths::Max(prevDim.x, restDim.x), prevDim.y + restDim.y);
                }
                else
                {
                    return dim;
                }
            }
            // Reached the end of the text without exceeding the wrap width
            else if (nextIndex == -1)
            {
                lines.push_back(substr);
                // print("Added '" + substr + "' to lines array");

                // print("Substring '" + substr + "' is the entire text");
                return dim;
            }

            // print("Substring '" + substr + "' is too short");

            // Substring is yet to exceed wrap width, so remember index and continue
            index = nextIndex;
            firstWord = false;
        }

        // Impossible path
        return Vec2f_zero;
    }

    Vec2f getMinBounds()
    {
        if (calculateMinBounds)
        {
            // This will set calculateMinBounds back to false
            Vec2f stackMinBounds = StandardStack::getMinBounds();

            if (wrap && minSize.x > 0.0f)
            {
                // Wrap using the standard stack bounds
                float trueMinWidth = stackMinBounds.x - margin.x * 2.0f;

                lines.clear();
                GUI::SetFont(font);
                textDim = calculateWrappedTextDimensions(text, trueMinWidth, lines);

                Vec2f labelMinSize = textDim + margin * 2.0f;

                // Pick the larger bounds
                minBounds.x = Maths::Max(stackMinBounds.x, labelMinSize.x);
                minBounds.y = Maths::Max(stackMinBounds.y, labelMinSize.y);
            }
            else
            {
                // Get dimensions for the line of text
                Vec2f labelBounds;
                GUI::SetFont(font);
                GUI::GetTextDimensions(text, labelBounds);

                // Add margin
                labelBounds += margin * 2.0f;

                // Pick the larger bounds
                minBounds.x = Maths::Max(stackMinBounds.x, wrap ? 0.0f : labelBounds.x);
                minBounds.y = Maths::Max(stackMinBounds.y, labelBounds.y);
            }
        }

        return minBounds;
    }

    Vec2f getBounds()
    {
        if (calculateBounds)
        {
            // This will set calculateBounds back to false
            bounds = StandardStack::getBounds();

            lines.clear();
            GUI::SetFont(font);
            textDim = calculateWrappedTextDimensions(text, getTrueBounds().x, lines);
        }

        return bounds;
    }

    private bool canRender()
    {
        return text != "" && (!wrap || minSize.x > 0.0f);
    }

    void Render()
    {
        if (canRender())
        {
            // The hardcoded offset correctly aligns the text within the bounds
            // May only be applicable with the default KAG font?
            Vec2f truePosition = getTruePosition() - Vec2f(2, 2);
            Vec2f trueBounds = getTrueBounds();
            Vec2f alignment = getAlignment();
            Vec2f boundsDiff = trueBounds - textDim;
            uint lineCount = lines.size();

            Vec2f position;
            position.x = truePosition.x + boundsDiff.x * alignment.x;
            position.y = truePosition.y + boundsDiff.y * alignment.y;

            GUI::SetFont(font);

            // A custom line wrapping implementation is used because of an engine bug:
            // https://github.com/transhumandesign/kag-base/issues/1964
            for (uint i = 0; i < lineCount; i++)
            {
                float yOffset = i / float(lineCount) * textDim.y;
                GUI::DrawText(lines[i], position + Vec2f(0.0f, yOffset), color);
            }
        }

        StandardStack::Render();
    }
}
