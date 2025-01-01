import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vigenesia_app/model/user.dart';

class UserProvider extends StateNotifier<UserModel?> {
  UserProvider() : super(null);

  // Metode untuk login (mengupdate state dengan data dari JSON)
  void login(Map<String, dynamic> json) {
    state = UserModel.fromJson(json);
  }

  void loginWithModel(UserModel user) {
    state = user;
  }

  // Metode untuk logout (menghapus data user)
  void logout() {
    state = null; // Set state menjadi null saat logout
  }

  void updateAvatar(String newAvatarLink){
    if (state != null){
      state = state!.copyWith(
        avatarLink: newAvatarLink 
      );
    }
  }

  // Metode untuk mengupdate data user
  void updateUserData(UserModel updateUser) {
    if (state != null) {
      state = updateUser;
    }
  }
}

// Deklarasi StateNotifierProvider yang mendukung nilai null untuk UserModel
final userProvider = StateNotifierProvider<UserProvider, UserModel?>((ref) {
  return UserProvider();
});
