namespace MuulfzRP.Server
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using CitizenFX.Core;
    using Configurations;
    using Model;
    using Storage;

    public class Base : BaseScript
    {
        private static BaseConfig BaseConfig;
        private readonly UserRepository _userRepository; //TODO Iniciar isso
        private readonly UserDataRepository _userDataRepository; //TODO Iniciar isso
        private readonly CharacterRepository _characterRepository; //TODO Iniciar isso

        public Base()
        {
            BaseConfig = new BaseConfig();


            
        }


        public static BaseConfig GetConfiguration()
        {
            return BaseConfig;
        }

        [EventHandler("playerConnecting")]
        public async void OnPlayerConnecting([FromSource] Player player, string playerName, dynamic setKickReason,
            dynamic deferrals)
        {
            deferrals.defer();

            await Delay(0);

            IdentifierCollection identifierCollection = player.Identifiers;

            if (identifierCollection.Any())
            {
                deferrals.update("Checking identifiers...");
                Identifiers identifiers = new Identifiers(identifierCollection);
                User user = _userRepository.FindUserOrCreateNew(identifiers);

                if (user != null)
                {
                    deferrals.update("Checking banned...");
                    if (!user.Banned)
                    {
                        deferrals.update("Checking whitelisted...");
                        if (!BaseConfig.Whitelist || user.Whitelisted)
                        {
                            string sourceLogged;

                            if (!MuulfzRP.Sources.TryGetValue(user.Id, out sourceLogged))
                            {
                                deferrals.update("Loading user...");
                                UserData userData = _userDataRepository.GetByUserId(user.Id);
                                if (userData == null)
                                {
                                    userData = new UserData();
                                    _userDataRepository.Add(userData);
                                    _userDataRepository.SaveChanges();
                                }

                                MuulfzRP.Sources.Add(user.Id, player.Handle);
                                MuulfzRP.Users.Add(player.Handle, user.Id);

                                user.Name = playerName;

                                user.EndPoint = player.EndPoint;

                                deferrals.update("Loading character...");

                                Character character = _characterRepository.FindById(
                                    userData.CurrentCharacter);

                                if (character == null)
                                {
                                    List<Character> characterList = _characterRepository.FindAllByUser(user.Id);
                                    if (characterList.Count > 0)
                                    {
                                        character = characterList.First();
                                    }
                                    else
                                    {
                                        character = new Character();
                                        user.characters.Add(character);
                                        _userDataRepository.SaveChanges();
                                    }
                                }

                                user.LastLogin = DateTime.Now;


                                //Player JoinEvent send id and Character id ??
                                deferrals.done();

                            }

                            Console.WriteLine($"{user.Name} ({user.EndPoint}) re - joined(user_id = ..{user.Id}..)");
                            MuulfzRP.Users.Remove(sourceLogged);

                            MuulfzRP.Users.Add(player.Handle, user.Id);
                            MuulfzRP.Sources[user.Id] = player.Handle;

                            //TRIGGER EVENT REJOIN
                            deferrals.done();
                        }
                    }
                }
            }
        }
    }
}