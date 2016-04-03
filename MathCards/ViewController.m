//
//  ViewController.m
//  MathCards
//
//  Created by Michael Maloof on 4/3/16.
//  Copyright © 2016 Jetpack Dinosaur. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

//the interface contains all the properties of the ViewController.

@property int highScore;
@property int firstNumber;
@property int secondNumber;
@property int answer;
@property int totalCorrectAnswers;
@property int totalIncorrectAnswers;
@property int totalStreak;
@property int typeOfQuestion;
@property NSTimer *answerTimer;
@property int seconds;

//the properties with gray circles next to them and the word IBOutlet are properties created in the storyboard.

@property (weak, nonatomic) IBOutlet UITextField *answerTextField;
@property (weak, nonatomic) IBOutlet UILabel *displayTimer;
@property (weak, nonatomic) IBOutlet UILabel *leftNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *mathSymbolLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *rightAnswersLabel;
@property (weak, nonatomic) IBOutlet UILabel *wrongAnswersLabel;
@property (weak, nonatomic) IBOutlet UILabel *highscoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *streak;
@property (weak, nonatomic) IBOutlet UILabel *medal;


@end

//the implementation contains all of the logic that occurs within the ViewController. More specifically, it tells the methods what to do when they are called.

@implementation ViewController


//viewDidLoad is the first method the viewController calls. It calls it once its loaded and the screen is about to appear.

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //the line below refers to the keyboardType property of the answerTextField. The answerTextField is itself a property of the ViewController (which is refered to as self). In this case, were setting the keyboardType to UIKeyboardTypeNumberPad , which is the numeric keyboard instead of letters. We do this to make it easier for the user to select numbers only.
    self.answerTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    //the game starts with just the "start" button and "highscore" showing, so we need to hide all the storyboard elements that shouldnt be showing when the app first loads.
    [self hideElementsForStart];
    
    //load the user's high score
    [self loadHighscore];
}

//the method below, startButtonWasTapped, is called when the user taps the start button. The gray circle indicates the storyboard is what handles this tap. The code inside the method is the logic that occurs when the method is called (or when the button is clicked).
- (IBAction)startButtonWasTapped:(id)sender {
    
    //when the user taps start, the game begins. Unhide all the elements they need to see
    
    self.answerTextField.hidden = NO;
    self.displayTimer.hidden = NO;
    self.leftNumberLabel.hidden = NO;
    self.mathSymbolLabel.hidden = NO;
    self.rightNumberLabel.hidden = NO;
    self.rightAnswersLabel.hidden = NO;
    self.wrongAnswersLabel.hidden = NO;
    self.submitButton.hidden = NO;
    
    //and hide the start button since the game has already started
    
    self.startButton.hidden = YES;
    
    //ask the first question
    [self askQuestion];
}

//the method below, submitButtonWasTapped, is called when the user taps the submit button. The gray circle indicates the storyboard is what handles this tap. The code inside the method is the logic that occurs when the method is called (or when the button is clicked).
- (IBAction)submitButtonWasTapped:(id)sender {
    
    [self answerQuestion];
    
}

-(void)askQuestion{
    
    //invalide the timer and set it to nil to prevent multiple timers from going off
    [self.answerTimer invalidate];
    self.answerTimer = nil;
    
    //set the amount of seconds that have passed to answer to 0
    self.seconds = 0;
    
    // check to see if the user has answer 10 questions correctly in a row (streak of 10)
    if (self.totalStreak < 10) {
        
        self.streak.textColor = [UIColor whiteColor];
        
        //the user has not reached a streak of 10, so only numbers up to 9 will be asked.
        
        //arc4random_uniform is a method that randomly selects a number for you. If you put 10 inside the ( ) it will give you a number from 1-9
        self.firstNumber = arc4random_uniform(10);
        self.secondNumber = arc4random_uniform(10);
        
        
    }else if (self.totalStreak >= 10) {
        
        //the user has reached a streak of 10, so numbers up to 19 will be asked and we change the color of the streak label
        self.streak.textColor = [UIColor orangeColor];
        
        //arc4random_uniform is a method that randomly selects a number for you. If you put 20 inside the ( ) it will give you a number from 1-19
        self.firstNumber = arc4random_uniform(20);
        self.secondNumber = arc4random_uniform(20);
        
    }
    
    //using our arc4random logic above, we now have two integers. We need to now figure out if the user is going to add, subtract, or multiply those integers for their answer. We will use arc4random again for this.
    
    //since we dont use divide (avoiding floats), we set arc4random to 3. if its 0, its addition, 1 is subtraction, 2 is multiplication.
    
    self.typeOfQuestion = arc4random_uniform(3);
    
    if (self.typeOfQuestion == 0) {
        
        self.answer = self.firstNumber + self.secondNumber;
        
        self.mathSymbolLabel.text = @"+";
        
    }else if (self.typeOfQuestion == 1) {
        
        //make sure we cant get negative answers
        if (self.firstNumber >= self.secondNumber) {
            
            self.answer = self.firstNumber - self.secondNumber;
            
            self.mathSymbolLabel.text = @"-";
            
        }else{
            
            self.secondNumber = arc4random_uniform(self.firstNumber);
            
            self.answer = self.firstNumber - self.secondNumber;
            
            self.mathSymbolLabel.text = @"-";
        }
        
    }else if (self.typeOfQuestion == 2) {
        
        self.answer = self.firstNumber * self.secondNumber;
        
        self.mathSymbolLabel.text = @"x";
        
    }
    
    //update the labels for the user to read the math equation
    
    self.leftNumberLabel.text = [NSString stringWithFormat:@"%d",self.firstNumber];
    
    self.rightNumberLabel.text = [NSString stringWithFormat:@"%d",self.secondNumber];
    
    //start the timer for them to answer
    self.answerTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                        target: self
                                                      selector:@selector(addSecond)
                                                      userInfo: nil
                                                       repeats:YES];
    
}

//the method below, loadHighscore, uses NSUserDefaults to load the user's high score from the phone and then to display that high score on the highcoreLabel
-(void)loadHighscore{
    
    self.medal.hidden = YES;
    
    //first, we create an NSUserDefalt
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //then we set self.highScore to the int held in the NSUserDefalt
    self.highScore = (int)[defaults integerForKey:@"HighScore"];
    //then we convert the int into a string and set the highscoreLabel equal to it
    self.highscoreLabel.text = [NSString stringWithFormat:@"High Score: %d",self.highScore];
    
    [self updateMedal];
    
    
}

//logic on if you should see the medal next to the high score
-(void)updateMedal{
    //we dont want the label to have text
    self.medal.text = @"";
    
    //make the label round
    self.medal.layer.cornerRadius = 5.0;
    self.medal.layer.masksToBounds = YES;
    
    //based on the score, change the color of the label
    if (self.highScore > 29){
        self.medal.backgroundColor = [UIColor colorWithRed:222.0/255.0 green:185.0/255.0 blue:24.0/255.0 alpha:1.0];
        self.medal.hidden = NO;
    } else if (self.highScore > 19){
         self.medal.backgroundColor = [UIColor colorWithRed:193.0/255.0 green:185.0/255.0 blue:186.0/255.0 alpha:1.0];
        self.medal.hidden = NO;
    } else if (self.highScore > 9){
         self.medal.backgroundColor = [UIColor colorWithRed:174.0/255.0 green:89.0/255.0 blue:15.0/255.0 alpha:1.0];
        self.medal.hidden = NO;
    } else {
        self.medal.hidden = YES;
    }
}

//the method below, hideElementsForStart, uses the hidden property (a BOOLEAN) of the element and sets it to NO to hide it.
-(void)hideElementsForStart{
    
    self.answerTextField.hidden = YES;
    self.displayTimer.hidden = YES;
    self.leftNumberLabel.hidden = YES;
    self.mathSymbolLabel.hidden = YES;
    self.rightNumberLabel.hidden = YES;
    self.rightAnswersLabel.hidden = YES;
    self.wrongAnswersLabel.hidden = YES;
    self.submitButton.hidden = YES;
    self.streak.hidden = YES;
    
    //also, to avoid the labels showing the storyboard values, we set their text to blank to begin.
    
    self.answerTextField.text = @"";
    self.displayTimer.text = @"";
    self.leftNumberLabel.text = @"";
    self.mathSymbolLabel.text = @"";
    self.rightNumberLabel.text = @"";
    self.rightAnswersLabel.text = @"Right Answers: 0";
    self.wrongAnswersLabel.text = @"Wrong Answers: 0";
    self.streak.text = @"";
    
}

//the user answered the question, check if they're correct
-(void)answerQuestion{
    
    //convert the string they typed into the text field into an int.
    int userAnswerInt = [self.answerTextField.text intValue];
    
    //invalidate the timer to make it stop while youre checking the answer
    [self.answerTimer invalidate];
    self.answerTimer = nil;
    
    // IF THE ANSWER IS CORRECT
    if (userAnswerInt == self.answer) {
        
        //change the background color to show the answer was correct
        self.view.backgroundColor =  self.view.backgroundColor = [UIColor colorWithRed:171.0/255.0 green:222.0/255.0 blue:165.0/255.0 alpha:1.0];
        
        //clear the textfield text
        self.answerTextField.text = nil;
        
        //add one to the total correct anwers
        self.totalCorrectAnswers +=1;
        
        //update how many they've answered right on the label
        self.rightAnswersLabel.text = [NSString stringWithFormat:@"Right: %d",self.totalCorrectAnswers];
        
        //add one to their streak
        self.totalStreak +=1;
        
        //the streak is greater than 0 (meaning theyre on a streak) so unhide the label
        self.streak.hidden = NO;
        
        //set the label to the streak
        self.streak.text = [NSString stringWithFormat:@"%d",self.totalStreak];
        
        //if the current streak is higher than the previous highscore, set a new high score.
        if (self.totalStreak > self.highScore) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:self.totalStreak forKey:@"HighScore"];
            [defaults synchronize];
            self.highscoreLabel.text = [NSString stringWithFormat:@"High Score: %d",self.highScore];
            [self updateMedal];
        }
        
        //ask another question
        [self askQuestion];
        
        // IF THE ANSWER IS INCORRECT
        
    }else if (userAnswerInt != self.answer) {
        
        //change background color to red to show they were wrong
        self.view.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1.0];
        
        //clear the answer textfield
        self.answerTextField.text = nil;
        
        //add one to the inccorect answers
        self.totalIncorrectAnswers +=1;
        
        //update the wrongAnswersLabel
        self.wrongAnswersLabel.text = [NSString stringWithFormat:@"Wrong: %d",self.totalIncorrectAnswers];
        
        //if the current streak is higher than the previous highscore, set a new high score.
        if (self.totalStreak > self.highScore) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:self.totalStreak forKey:@"HighScore"];
            [defaults synchronize];
            self.highscoreLabel.text = [NSString stringWithFormat:@"High Score: %d",self.highScore];
            [self updateMedal];
        }
        
        //reset the high score
        self.totalStreak = 0;
        
        //no streak, so hide the label
        self.streak.hidden = YES;
        
        //ask another question
        [self askQuestion];
        
    }

}

//the method below, addSecond, adds a second to the timer. It is called every second by the timer.
- (void) addSecond {
    
    self.seconds += 1;
    
    // If self.seconds == 10, the user is out of time and the answer is wrong
    
    if (self.seconds == 10) {
        
        //answer is wrong (out of time), turn view red
        self.view.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1.0];
        
        //clear the text field
        self.answerTextField.text = nil;
        
        //add one to inccorect answers
        self.totalIncorrectAnswers +=1;
        
        //update wrong answer label
        self.wrongAnswersLabel.text = [NSString stringWithFormat:@"Wrong: %d",self.totalIncorrectAnswers];
        
        //if the user broke their high score, update it
        if (self.totalStreak > self.highScore) {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            [defaults setInteger:self.totalStreak forKey:@"HighScore"];
            
            [defaults synchronize];
            
            //reset total streak to 0
            self.totalStreak = 0;
            
        }
        //not on a streak, so hide the label
        self.streak.hidden = YES;
        
        //ask another question
        [self askQuestion];
        
    }
    //update the timer label
    self.displayTimer.text = [NSString stringWithFormat:@"%d",self.seconds];
    
}



@end
