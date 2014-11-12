package canoe.sample.service
{
	import canoe.sample.utils.HTTPService;
	import canoe.util.Closure;

	public class LoginService
	{
		public static const instance : LoginService = new LoginService();
		
		public function login(passport : String, password : String, onlogin : Closure) : void
		{
			if (passport.length <= 0)
			{
				alert("用户名不能为空");
				return;
			}
			
			if (password.length <= 0)
			{
				alert("密码不能为空");
				return;
			}
			
			HTTPService.doPost('http://api.sg.gamedo.mobi/', {
				act:'Index.login', 
				passport:passport, 
				password:password
			}, onlogin);
		}
	}
}