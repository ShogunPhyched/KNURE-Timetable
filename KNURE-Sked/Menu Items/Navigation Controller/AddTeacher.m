//
//  TeacherListAddTeacher.m
//  KNURE-Sked
//
//  Created by Влад on 1/5/14.
//  Copyright (c) 2014 Влад. All rights reserved.
//

#import "AddTeacher.h"
#import "TeacherList.h"
#import "EventHandler.h"

@interface AddTeacher ()

@end

@implementation AddTeacher

@synthesize teacherSearchBar, teachersTableView;

#pragma mark - view

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    shoudOffPanGesture = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults] setValue:teacherList forKey:@"SavedTeachers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    allResults = [[NSMutableArray alloc] init];
    selectedTeachers = [[NSMutableArray alloc]init];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"SavedTeachers"] != nil) {
        selectedTeachers = [[[NSUserDefaults standardUserDefaults] valueForKey:@"SavedTeachers"] mutableCopy];
    }
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.delegate = self;
    HUD.labelText = @"Загружаю список...";
    [self getTeacherList];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    shoudOffPanGesture = NO;
    [[NSUserDefaults standardUserDefaults] setObject:selectedTeachers forKey:@"SavedTeachers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - logic

- (void)getTeacherList {
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:@"http://cist.kture.kharkov.ua/ias/app/tt/P_API_PODR_JSON"]];
    [HUD show:YES];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if(!data) {
                                   UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Ошибка"
                                                                                      message:@"Не удалось получить ответ от сервера"
                                                                                     delegate:self
                                                                            cancelButtonTitle:@"Понятно"
                                                                            otherButtonTitles:nil,
                                                             nil];
                                   [HUD hide:YES];
                                   [alertView show];
                                   return;
                               }
                               
                               NSData *encData = [[EventHandler alloc]alignEncoding:data];
                               NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:encData options:0 error:&error];
                               allResults = [self getKeysAndTitles:parsedData];
                               [self.teachersTableView reloadData];
                               [HUD hide:YES];
                           }
     ];
}

- (NSMutableArray *)getKeysAndTitles:(NSDictionary *)source {
    NSMutableArray *groupsAndKeys = [[NSMutableArray alloc]init];
    NSString *updated = @"Не обновлено";
    NSArray *facultList = [[source valueForKey:@"university"] valueForKey:@"faculties"];
    
    for(NSDictionary *department in facultList) {
        for(NSArray *teachers in [[department valueForKey:@"departments"] valueForKey:@"teachers"]) {
            for (NSDictionary *teacher in teachers) {
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [teacher valueForKey:@"short_name"], @"title",
                                            [[teacher valueForKey:@"id"] stringValue], @"key",
                                            updated, @"updated", nil];
                [groupsAndKeys addObject:dictionary];
            }
        }
    }
    return groupsAndKeys;
}

- (int)getIndexOfString:(NSString *)text inArray:(NSMutableArray *)array {
    for (int i = 0; i < array.count; i++) {
        if ([[array objectAtIndex:i] containsObject:text]) {
            return i;
        }
    }
    return 0;
}

#pragma mark - search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(searchText.length == 0) {
        isFiltred = NO;
    } else {
        isFiltred = YES;
        searchResults = [[NSMutableArray alloc]init];
        for(NSString *teacher in [allResults valueForKey:@"title"]) {
            NSRange teacherNameRange = [teacher rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(teacherNameRange.location != NSNotFound) {
                [searchResults addObject:teacher];
            }
        }
    }
    [self.teachersTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (isFiltred==YES)?searchResults.count:allResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [allResults objectAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.text = (isFiltred)?[searchResults objectAtIndex:indexPath.row]:[[allResults objectAtIndex:indexPath.row]valueForKey:@"title"];
    cell.detailTextLabel.text = ([[selectedTeachers valueForKey:@"title"] containsObject:cell.textLabel.text])? @"добавлено" : @"";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (![selectedTeachers containsObject:cell.textLabel.text]) {
        [selectedTeachers addObject:[allResults objectAtIndex:[self getIndexOfString:cell.textLabel.text inArray:allResults]]];
    }
    cell.detailTextLabel.text = @"добавлено";
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
