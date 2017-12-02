class student {
private:
    int age;
    float score;
public:
    int ShowInfo(int key, int option);
    int SetInfo(int _age, float _score);
    int Study();
    int Sleep();
}

int student::ShowInfo(int key, int option)
{
    student stu;
    stu.Study(15, 5.5);
}

int main()
{
    student stu;
    int sample_int = 10;
    float sample_float = 50.5;
    int i;

    while (sample_int == sample_float) {
	int a = 30;
	float b = 20.21;

	stu.Study();
	stu.Sleep();
    }

    if (sample_int > 30) {
	student newStudent;
	newStudent.ShowInfo(10, -9);
	if (sample_int > 50) {
	    int double_if;
	    stu.Sleep();
	}
	if (sample_int > 70) {
	    int double_if;
	    stu.Study();
	}
    }
    else {
	int key = 15;
	sample_int = sample_int + 30;
    }

    for (1; i <= 10; 1) {
	int for_int;
	for_int = sample_int + i;
    }

    return 0;
}
