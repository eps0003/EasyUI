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
    private Vec2f textDim = Vec2f_zero;

    void SetText(string text)
    {
        if (this.text == text) return;

        this.text = text;

        CalculateMinBounds();
        DispatchEvent(Event::Text);
    }

    string getText()
    {
        return text;
    }

    void SetFont(string font)
    {
        if (this.font == font) return;

        this.font = font;

        CalculateMinBounds();
        DispatchEvent(Event::Font);
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

        CalculateMinBounds();
        DispatchEvent(Event::MaxLines);
    }

    uint getMaxLines()
    {
        return maxLines;
    }

    // Recursively determine the lines and dimensions of text that wraps at the specified width
    private Vec2f calculateWrappedTextDimensions(string text, float wrapWidth, string[] &inout lines)
    {
        // No text to process
        if (text == "")
        {
            return Vec2f_zero;
        }

        uint index = 0;
        bool firstWord = true;

        string[] allFitText;
        Vec2f[] allFitDim;

        // Skip spaces before the first word
        while (text.substr(index, 1) == " ")
        {
            index++;
        }

        while (true) // o_O
        {
            // Get a substring with an increasing number of words
            uint nextIndex = text.find(" ", index + 1);
            string testText = text.substr(0, nextIndex);

            bool lastLine = maxLines > 0 && lines.size() == maxLines - 1;

            // Get substring dimensions
            Vec2f testDim;
            GUI::GetTextDimensions(testText, testDim);

            // Substring doesn't exceed the wrap width
            if (testDim.x <= wrapWidth || firstWord)
            {
                // Reached the end of the text without exceeding the wrap width
                if (nextIndex == -1)
                {
                    lines.push_back(testText);
                    return testDim;
                }
                else // Substring is yet to exceed wrap width, so remember index and keep iterating
                {
                    allFitText.push_back(testText);
                    allFitDim.push_back(testDim);

                    index = nextIndex;
                    firstWord = false;
                }
            }
            // Last line needs to be truncated by iteratively backtracking until the ellipsis fits
            else if (lastLine)
            {
                string fitText;
                Vec2f fitDim;

                for (int i = allFitText.size() - 1; i >= 0; i--)
                {
                    fitText = allFitText[i] + " ...";
                    GUI::GetTextDimensions(fitText, fitDim);

                    if (fitDim.x <= wrapWidth)
                    {
                        break;
                    }
                }

                lines.push_back(fitText);
                return fitDim;
            }
            else // Substring exceeds wrap width so it must wrap
            {
                string fitText = allFitText[allFitText.size() - 1];
                Vec2f fitDim = allFitDim[allFitDim.size() - 1];

                lines.push_back(fitText);

                // Skip spaces after the last word
                while (text.substr(index, 1) == " ")
                {
                    index++;
                }

                string rest = text.substr(index);

                // Width is the longest line and height is the sum of all lines
                Vec2f restDim = calculateWrappedTextDimensions(rest, wrapWidth, lines);
                return Vec2f(Maths::Max(fitDim.x, restDim.x), fitDim.y + restDim.y);
            }
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
        return (
            isVisible() &&
            text != "" &&
            (!wrap || minSize.x > 0.0f)
        );
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
