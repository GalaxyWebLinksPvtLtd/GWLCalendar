//  Created by GalaxyWeblinks on 11/01/18.
//  Copyright © 2017 GalaxyWeblinks. All rights reserved.
//

#import "ViewController.h"
#import "GWLCalenderVC.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *selectedLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.selectedLabel.text = @"";
    [self setTitle:@"GWL"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionOnTap:(id)sender {
    self.selectedLabel.text = @"";
    GWLCalenderVC *aGWLCalenderVC = [[GWLCalenderVC alloc] init];
    [aGWLCalenderVC initializeController:self timeIntervel:30 completion:^(NSDate *dateObject) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"MM/dd/yyyy HH:mm"];
        NSLog(@"%@",dateObject);
        self.selectedLabel.text = [formatter stringFromDate:dateObject];
    }];
}

@end
