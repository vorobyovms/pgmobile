//
//  ViewController.swift
//  PG
//
//  Created by михаил on 7/21/19.
//  Copyright © 2019 михаил. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sms.text = "Введіть номер телефону"
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var sms: UITextField!
    
    @IBAction func TouchDownNumber(_ sender: UITextField) {
        sms.text = "0";
        sms.addTarget(nil, action:Selector(("firstResponderAction:")), for:.editingDidEndOnExit)
    }

    
    //@IBAction func textField(_ sender: AnyObject) {
    //    self.view.endEditing(true);
    //}

    @IBAction func auth(_ sender: UIButton) {
        print("press button");
        //preloader
        let alert_personal = UIAlertController(title: nil, message: "Будь ласка зачекайте - перевіряється Ваш телефон серед персоналу!", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert_personal.view.addSubview(loadingIndicator)

        let frommobile = sms.text;
        let numberRegExp:String = "^\\d{10,20}";        //pattern for mobile telephone
        print(sms as Any);
        let telephonCheck = NSPredicate(format:"SELF MATCHES %@", numberRegExp);
        let result = telephonCheck.evaluate(with: frommobile);
        print("result check telephone ",result);
        if(result == true) {
            //ответ который приходит с сервера
            print("отправим запрос на поиск мобильного номера");
            //{"telephone":"0504502332"}
            //let sendParamTel = JSON(["telephone":frommobile]);
            var status = "";
            let json = ["telephone":frommobile];
            let jsonData = try? JSONSerialization.data(withJSONObject: json);
            print(jsonData as Any);
            let url_send = "http://116.203.121.110:888/CheckDataForPersonal"; // отправка url запроса
            print(url_send);
            let url = URL(string: url_send)!
            var request = URLRequest(url: url);
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            //show preloader
            present(alert_personal, animated: true, completion: nil);
            
            //Начало запроса
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 30.0
            let urlsess = URLSession(configuration: sessionConfig);
            
            //http query try catch
                let task = urlsess.dataTask(with: request) { data, response, error in
                print("response = ", response as Any)
                    
                //если нет связи с сервером вообще
                if response == nil {
                    DispatchQueue.main.async {
                        self.dismiss(animated: false) {
                            OperationQueue.main.addOperation {
                                let alert1 = UIAlertController(title: "Авторізація PravoGarant", message: "Помілка зв'язку з сервером - спробуйте пізніше", preferredStyle: .alert)
                                alert1.addAction(UIAlertAction(title: "Так", style: .default, handler: { action in
                                    self.sms.text = "0";
                                }))
                                UIApplication.shared.keyWindow?.rootViewController?.present(alert1, animated: true)
                            }
                        }
                        
                    }
                    return
                }
                    
                guard let data = data, error == nil else {
                    //ошибка соединения с сервером
                    print("error = ",error as Any)
                    print(error?.localizedDescription ?? "No data")
                    DispatchQueue.main.async {
                        self.dismiss(animated: false, completion: nil)
                        let alert = UIAlertController(title: "Авторізація PravoGarant", message: "Помілка зв'язку з сервером - спробуйте пізніше", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Так", style: .default, handler: { action in
                            self.sms.text = "0";
                        }))
                        self.present(alert, animated: true)
                    }
                    return
                }
                    //окончание показаза крутилки
                    DispatchQueue.main.async {
                        self.dismiss(animated: false, completion: nil)
                    }
                
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                print("responseJSON before = \(String(describing: responseJSON))");
                
                if let responseJSON = responseJSON as? [String: Any] {
                    print("good answer = \(responseJSON)")
                    var good_answer:[String: Any] = responseJSON;
                    print("zapomnim = \(good_answer)");
                    print(type(of: good_answer));
                    status = good_answer["status"] as! String;
                    let personal_id = good_answer["personal_id"];
                    
                    //self.login_telephone = good_answer["telephone"] as! String;
                    
                    print("status as = \(String(describing: good_answer["status"]))");
                    print("personal id ",personal_id as Any)
                    
                    //Если пришел нужный ответ
                    if(status.contains("200")) {
                        //переход на другую форму
                        DispatchQueue.main.async {
                            print("Ответ положительный");
                            // переход на вторую страницу
                            let viewController  = self.storyboard!.instantiateViewController(withIdentifier: "PassAuth") as! Auth2ViewerViewController;
                            viewController.modalPresentationStyle = .fullScreen;
                            viewController.tellogin = self.sms.text!
                            //viewController.personalid = personal_id as Any as! String
                            viewController.personalid = String(format: "%@", personal_id as! CVarArg)
                            //personal id
                            self.present(viewController, animated: false, completion: nil)
                        }
                    }
                    
                    //Если номер не обнаружен
                    if(status.contains("404")) {
                        print("Номер не найден");
                        
                        //если номер не найден то алерт
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Авторізація PravoGarant", message: "Такого номеру не існує", preferredStyle: .alert)
                            self.present(alert, animated: true)
                            alert.addAction(UIAlertAction(title: "Так", style: .default, handler: { action in
                                self.sms.text = "0";
                            }))
                        }
                    }
                }
            }
            task.resume();
            //Конец запроса
            
            
            print("status = \(status)");
            //Смотрим ответ
        } else if(result == false) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Авторізація PravoGarant", message: "Невірний формат номеру телефона. Номер телефона містить лише цифри та повинен складатись не менше, чим з 10 символів", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Так", style: .default, handler: { action in
                    self.sms.text = "0";
                }))
                self.present(alert, animated: true)
                
            }
        }
    }
}

