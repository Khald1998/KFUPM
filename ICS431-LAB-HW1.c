#include <stdio.h>
#include <string.h>

int main() {
    int numCourses;
    printf("How many courses?\n");
    scanf("%d", &numCourses);

    char grades[numCourses][3];
    int creditHours[numCourses];

    printf("Enter letter grade, credit hours for %d courses:\n", numCourses);
    for (int i = 0; i < numCourses; i++) {
        scanf("%s %d", grades[i], &creditHours[i]);
    }

    double totalGradePoints = 0.0;
    int totalCreditHours = 0;

    for (int i = 0; i < numCourses; i++) {
        double gradePoint = 0.0;

        if (strcmp(grades[i], "A+") == 0) {
            gradePoint = 4.0;
        } else if (strcmp(grades[i], "A") == 0) {
            gradePoint = 3.75;
        } else if (strcmp(grades[i], "B+") == 0) {
            gradePoint = 3.5;
        } else if (strcmp(grades[i], "B") == 0) {
            gradePoint = 3.0;
        } else if (strcmp(grades[i], "C+") == 0) {
            gradePoint = 2.5;
        } else if (strcmp(grades[i], "C") == 0) {
            gradePoint = 2.0;
        } else if (strcmp(grades[i], "D+") == 0) {
            gradePoint = 1.5;
        } else if (strcmp(grades[i], "D") == 0) {
            gradePoint = 1.0;
        } else if (strcmp(grades[i], "F") == 0) {
            gradePoint = 0.0;
        } else {
            printf("Invalid grade entered: %s\n", grades[i]);
            return 1; 
        }

        totalGradePoints += gradePoint * creditHours[i];
        totalCreditHours += creditHours[i];
    }

    double gpa = totalGradePoints / totalCreditHours;
    printf("GPA = %.2lf\n", gpa);

    return 0;
}
