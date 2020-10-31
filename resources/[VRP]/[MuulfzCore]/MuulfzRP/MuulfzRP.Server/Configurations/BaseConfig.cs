namespace MuulfzRP.Server.Configurations
{
    public class BaseConfig
    {
        public bool Whitelist = true;
        public UserConfig User = new UserConfig();

    }

    public class UserConfig
    {
        public CharacterConfig Character = new CharacterConfig();

    }

    public class CharacterConfig
    {
        public int Max = 2;
    }
}