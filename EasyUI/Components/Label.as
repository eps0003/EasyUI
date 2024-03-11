interface Label : Stack
{
    void SetText(string text);
    string getText();

    void SetFont(string font);
    string getFont();

    void SetColor(SColor color);
    SColor getColor();
}

class StandardLabel : Label, StandardStack
{
    private string text = "";
    private string font = "menu";
    private SColor color = color_black;

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

    Vec2f getMinBounds()
    {
        if (calculateMinBounds)
        {
            // This will set calculateMinBounds back to false
            Vec2f stackMinBounds = StandardStack::getMinBounds();

            // Get dimensions for the line of text
            Vec2f labelMinBounds;
            GUI::SetFont(font);
            GUI::GetTextDimensions(text, labelMinBounds);

            // If a minimum size is configured, it is an area label
            // x is the area label width; y is at least one line tall
            if (minSize.x != 0.0f || minSize.y != 0.0f)
            {
                labelMinBounds.x = minSize.x;
                labelMinBounds.y = Maths::Max(labelMinBounds.y, minSize.y);
            }

            // Take into account padding and margin
            labelMinBounds.x = Maths::Max(labelMinBounds.x, padding.x * 2.0f) + margin.x * 2.0f;
            labelMinBounds.y = Maths::Max(labelMinBounds.y, padding.y * 2.0f) + margin.y * 2.0f;

            // Pick the larger bounds
            minBounds.x = Maths::Max(stackMinBounds.x, labelMinBounds.x);
            minBounds.y = Maths::Max(stackMinBounds.y, labelMinBounds.y);
        }

        return minBounds;
    }

    void Render()
    {
        if (text != "")
        {
            // The magic values correctly align the text within the bounds
            // May only be applicable with the default KAG font?
            Vec2f position = getTruePosition() - Vec2f(2, 2);
            Vec2f bounds = getTrueBounds();

            GUI::SetFont(font);
            GUI::DrawText(text, position, position + bounds, color, false, false);
        }

        StandardStack::Render();
    }
}
