//
//  Auth2ViewerViewController.swift
//  PG
//
//  Created by михаил on 01.04.2020.
//  Copyright © 2020 михаил. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class Auth2ViewerViewController: UIViewController {
    
    var tellogin: String = "";
    var personalid: Any = "";

    @IBOutlet weak var Login: UILabel!
    @IBOutlet weak var SMSCode: UITextField!
    @IBOutlet weak var EnterToCRM: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("telephon auth 2 =",self.tellogin)
        print("auth2 personal id = ", self.personalid)
        Login.text = tellogin;
        SMSCode.addTarget(nil, action:Selector(("firstResponderAction:")), for:.editingDidEndOnExit)
    }

    
    @IBAction func GoToCRM(_ sender: Any) {
        
        let pass:String = SMSCode.text!
        
        print("SMS Code = ",pass)
        if(pass != "") {
            print("Otpravlyaem zapros na avtorizaciyu")
            let len_pass = pass.count as Int;
            if(len_pass >= 5) {
                //Если все хорошо и длина пароля больше или равно 5
                let alert = UIAlertController(title: "Авторізація PravoGarant", message: "Увага! Якщо Ваш пароль співпадає з паролем, який надійшов на електронну пошту натисніть Так - в іншому випадку Ні", preferredStyle: .alert)
                self.present(alert, animated: true)
                alert.addAction(UIAlertAction(title: "Так", style: .default, handler: { action in
                    print("Otpravlyaem zapros na avtorizaciyu")
                    
                    //подготовка http запроса
                    //{"telephone":"0504502332","secret":"k5Wuj","personal_id":2,"isroot":false}
                    
                    let code:String = self.SMSCode.text!
                    print("code from field = ",code)
                    let json = ["telephone":self.tellogin,"secret":code,"personal_id":self.personalid,"isroot":false]; //cам json запрос
                    let jsonData = try? JSONSerialization.data(withJSONObject: json);
                    print(jsonData as Any);
                    let url_send = "http://116.203.121.110:888/CheckSMSCode"; // отправка url запроса
                    print(url_send);
                    let url = URL(string: url_send)!
                    var request = URLRequest(url: url);
                    request.httpMethod = HTTPMethod.post.rawValue
                    request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                    request.httpBody = jsonData
                    //Начало запроса
                    let sessionConfig = URLSessionConfiguration.default
                    sessionConfig.timeoutIntervalForRequest = 30.0
                    let urlsess = URLSession(configuration: sessionConfig);
                    
                    //http hазборка
                    let task = urlsess.dataTask(with: request) { data, response, error in
                        
                        if response == nil {
                            DispatchQueue.main.async {
                                self.dismiss(animated: false) {
                                    OperationQueue.main.addOperation {
                                        let alert1 = UIAlertController(title: "Авторізація PravoGarant", message: "Помілка зв'язку з сервером - спробуйте пізніше", preferredStyle: .alert)
                                        alert1.addAction(UIAlertAction(title: "Так", style: .default, handler: { action in
                                            self.SMSCode.text = "";
                                        }))
                                        UIApplication.shared.keyWindow?.rootViewController?.present(alert1, animated: true)
                                    }
                                }
                                
                            }
                            return
                        }
                        
                        guard let data = data, error == nil else {
                            print("error = ",error as Any)
                            print(error?.localizedDescription ?? "No data")
                            DispatchQueue.main.async {
                                self.dismiss(animated: false, completion: nil)
                                let alert = UIAlertController(title: "Авторізація PravoGarant", message: "Помілка зв'язку з сервером - спробуйте пізніше", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Так", style: .default, handler: { action in
                                    self.SMSCode.text = "";
                                }))
                                self.present(alert, animated: true)
                            }
                            return
                        }
                        
                        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                        print("responseJSON before = \(String(describing: responseJSON))");
                        
                        //status
                        if let responseJSON = responseJSON as? [String: Any] {
                            print("good answer = \(responseJSON)")
                            var good_answer:[String: Any] = responseJSON;
                            print("zapomnim = \(good_answer)");
                            
                            let status = good_answer["status"];
                            print("status boolean = ",status as Any)
                            
                            if (status == nil) {
                                let token = good_answer["token"]
                                let token_str:String = String(format: "%@", token as! CVarArg)
                                print("token in string format = ",token_str)
                                let personal_id = good_answer["personal_id"]
                                print("personal_id = ",personal_id as Any)
                                let personal_id_convert = (good_answer["personal_id"]! as! CLong)
                                print("personal_id_convert = ",personal_id_convert)
                                
                                
                                DispatchQueue.main.async {
                                    //UserPage
                                    let viewController1  = self.storyboard!.instantiateViewController(withIdentifier: "UserPage") as! SWRevealViewController;
                                    viewController1.modalPresentationStyle = .fullScreen;  //Структура сохранения данных пользователя
                                    let storage = LocalStorage()
                                    storage.SaveData(id: personal_id_convert, token: token_str, telephone: self.tellogin)
  
                                self.present(viewController1, animated: false, completion: nil)
                                }
                            } else {
                                print("access denied")
                                //оповещение что срок жизни смс 15 мин и выего просрочили
                                DispatchQueue.main.async {
                                    let alert = UIAlertController(title: "Авторізація PravoGarant", message: "Статус: " + String(format: "%@", status as! CVarArg) + " доступ заборонено! Час введення тимчасовго паролю 15 хвилин з моменту отримання", preferredStyle: .alert)
                                    self.present(alert, animated: true)
                                    alert.addAction(UIAlertAction(title: "Так", style: .default, handler: { action in
                                            let viewController1  = self.storyboard!.instantiateViewController(withIdentifier: "CheckNumber") as! ViewController;
                                            viewController1.modalPresentationStyle = .fullScreen;
                                            self.present(viewController1, animated: false, completion: nil)

                                    }))
                                }
                            }
                        }
                        
                    }
                    task.resume();
                    //конец http
                    
                }))
                alert.addAction(UIAlertAction(title: "Ні", style: .default, handler: { action in
                    print(" Ne Otpravlyaem zapros na avtorizaciyu")
                    self.SMSCode.text = "";
                }))
            } else {
                //если длина пароля меньше 5
                let alert = UIAlertController(title: "Авторізація PravoGarant", message: "Мінімальна довжіна пароля 5 сімволів", preferredStyle: .alert)
                self.present(alert, animated: true)
                alert.addAction(UIAlertAction(title: "Так", style: .default, handler: { action in
                    self.SMSCode.text = "";
                }))
            }
        } else {
            print("Parol pustoy")
            let alert = UIAlertController(title: "Авторізація PravoGarant", message: "Пароль не може бути порожнім", preferredStyle: .alert)
            self.present(alert, animated: true)
            alert.addAction(UIAlertAction(title: "Так", style: .default))
        }
    }
}
