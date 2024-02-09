# Script to run the Speedometer 2.0 and 2.1 benchmarks using Selenium
# Laio O. Seman <laio@ieee.org>

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from time import sleep

def setup_driver():
    chrome_options = Options()
    chrome_options.binary_location = 'out/Release/chrome'  # Specify the path to Chrome binary here
    chrome_options.add_argument("--headless") 
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--window-size=1920,1080")
    chrome_options.add_argument("--disable-dev-shm-usage")
    driver = webdriver.Chrome(options=chrome_options)
    return driver

def run_speedometer(driver, version='2.0'):
    base_url = 'https://browserbench.org/Speedometer'
    if version not in ['2.0', '2.1']:
        print("Invalid Speedometer version specified. Defaulting to 2.0.")
        version = '2.0'
    full_url = f"{base_url}{version}/"
    driver.get(full_url)

    driver.save_screenshot(f"speedometer_{version}_start.png")

    start_button = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.TAG_NAME, "button")))
    start_button.click()

    # Wait for the details button to be visible
    details_button = WebDriverWait(driver, 60).until(EC.visibility_of_element_located((By.CLASS_NAME, "show-details")))
    details_button.click()

    driver.save_screenshot(f"speedometer_{version}_b.png")


def main():
    driver = setup_driver()
    try:
        # Run Speedometer 2.0
        run_speedometer(driver, '2.0')
        # Run Speedometer 2.1
        run_speedometer(driver, '2.1')
    finally:
        driver.quit()

if __name__ == "__main__":
    main()
