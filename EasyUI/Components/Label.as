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
        CalculateBounds();
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
        CalculateBounds();
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
        if (calculateBounds)
        {
            // Get dimensions for the line of text
            Vec2f dim;
            GUI::SetFont(font);
            GUI::GetTextDimensions(text, dim);

            // If a minSize is configured, it is an area label
            // x is the area label width; y is at least one line tall
            if (minSize.x != 0.0f || minSize.y != 0.0f)
            {
                dim.x = minSize.x;
                dim.y = Maths::Max(dim.y, minSize.y);
            }

            // Get minBounds without padding or margin
            // This will set calculateBounds back to false
            Vec2f trueMinBounds = StandardStack::getMinBounds() - (padding + margin) * 2.0f;

            // Determine the larger of the two bounds
            trueMinBounds.x = Maths::Max(trueMinBounds.x, dim.x);
            trueMinBounds.y = Maths::Max(trueMinBounds.y, dim.y);

            // Add back padding and margin
            minBounds = trueMinBounds + (padding + margin) * 2.0f;
        }

        return minBounds;
    }

    void Render()
    {
        if (text != "")
        {
            // The magic values correctly align the text within the bounds
            // May only be applicable with the default KAG font?
            Vec2f position = getTruePosition() - Vec2f(2, 1);
            Vec2f bounds = getTrueBounds();

            GUI::SetFont(font);
            GUI::DrawText(text, position, position + bounds, color, false, false);
        }

        StandardStack::Render();
    }
}
