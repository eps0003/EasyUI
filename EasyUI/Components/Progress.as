interface Progress : List
{
    void SetPercentage(float percentage);
    float getPercentage();
}

class StandardHorizontalProgress : Progress, StandardList
{
    private float percentage = 0.0f;

    void SetPercentage(float percentage)
    {
        percentage = Maths::Clamp01(percentage);

        if (this.percentage == percentage) return;

        this.percentage = percentage;

        DispatchEvent(Event::Percentage);
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
        if (!isVisible()) return;

        Vec2f min = getTruePosition();
        Vec2f max = min + getTrueBounds();

        GUI::DrawProgressBar(min, max, percentage);

        StandardList::Render();
    }
}
