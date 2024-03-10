interface Avatar : Stack
{
    void SetPlayer(CPlayer@ player);
    CPlayer@ getPlayer();
}

class StandardAvatar : Avatar, StandardStack
{
    private CPlayer@ player;

    void SetPlayer(CPlayer@ player)
    {
        @this.player = player;
    }

    CPlayer@ getPlayer()
    {
        return player;
    }

    bool canClick()
    {
        return true;
    }

    void Render()
    {
        Vec2f position = getTruePosition();
        Vec2f bounds = getTrueBounds();

        GUI::DrawRectangle(position, position + bounds, color_black);

        if (player !is null)
        {
            float scale = Maths::Min(bounds.x, bounds.y);
            Vec2f offset = Vec2f(bounds.x - scale, bounds.y - scale) * 0.5f;

            player.drawAvatar(position + offset, scale / 96.0f);
        }

        StandardStack::Render();
    }
}
