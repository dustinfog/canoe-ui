package canoe.sample.view{
	import flash.events.MouseEvent;
	
	import canoe.sample.service.LoginService;
	import canoe.util.Closure;

	public class LoginView extends _LoginView{

		override protected function create():void{
			super.create();
			
			btLogin.addEventListener(MouseEvent.CLICK, login_listener);
			btReg.addEventListener(MouseEvent.CLICK, reg_listener);
		}
		
		private function login_listener(event:MouseEvent):void
		{
			var passport:String = tfPassport.text;
			var password:String = tfPassword.text;
			
			LoginService.instance.login(passport, password, new Closure(trace));
		}
		
		private function reg_listener(event:MouseEvent):void
		{
			var passport:String = tfPassport.text;
			var password:String = tfPassword.text;
			
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
			
			alert("暂不开放，嘻嘻！");
			return;
		}
	}
}
