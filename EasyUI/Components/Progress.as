interface Progress : Stack
{
    void SetPercentage(float percentage);
    float getPercentage();
}

class StandardProgress : Progress, StandardStack
{
    private float percentage = 0.0f;

    void SetPercentage(float percentage)
    {
        percentage = Maths::Clamp01(percentage);

        if (this.percentage == percentage) return;

        this.percentage = percentage;

        DispatchEvent("change");
    }

    float getPercentage()
    {
        return percentage;
    }

    bool canClick()
    {
        return true;
    }

    void Render()
    {
        Vec2f min = getTruePosition();
        Vec2f max = min + getTrueBounds();
        Vec2f innerBounds = getInnerBounds();

        GUI::DrawProgressBar(min, max, percentage);

        StandardStack::Render();
    }
}
