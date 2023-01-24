using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;

public class CandleMelt : MonoBehaviour
{
    public SkinnedMeshRenderer candleStem;
    public GameObject fire;
    public GameObject startPoint;
    public GameObject endPoint;
    public TextMeshPro buttonText;
    public TextMeshProUGUI clockText;

    private float timeRemaining = 1800f;
    private float minutes = 0;
    private float seconds = 0;
    private bool started;
    private IEnumerator coroutine;

    // Start is called before the first frame update
    void Start()
    {
        FindRatio();
        minutes = Mathf.FloorToInt(timeRemaining / 60);
        seconds = Mathf.FloorToInt(timeRemaining % 60);
    }

    // Update is called once per frame
    void Update()
    {
        DisplayTime(timeRemaining);

        if (Input.GetKeyDown(KeyCode.Space))
        {
            ToggleButton();
        }
    }

    public void ToggleButton()
    {
        if(started)
        {
            StopTimer();
            started = false;
            buttonText.text = "Start";
        }
        else
        {
            StartTimer();
            started = true;
            buttonText.text = "Stop";
        }
    }

    public void StartTimer()
    {
        coroutine = Melt();
        StartCoroutine(coroutine);

    }

    public void StopTimer()
    {
        LightFlame(false);
        StopCoroutine(coroutine);
    }

    void DisplayTime(float timeToDisplay)
    {
        if(timeToDisplay >= 0)
        {
            float minutes = Mathf.FloorToInt(timeToDisplay / 60);
            float seconds = Mathf.FloorToInt(timeToDisplay % 60);
            clockText.text = string.Format("{0:00}:{1:00}", minutes, seconds);
        }
    }

    void FindRatio()
    {
        var value = (((startPoint.transform.localPosition - endPoint.transform.localPosition) / 100) * candleStem.GetBlendShapeWeight(0));
        fire.transform.localPosition = new Vector3(value.x, (startPoint.transform.localPosition.y - value.y), value.z);
    }


    void LightFlame(bool isLit)
    {
        fire.gameObject.SetActive(isLit);
    }

    public void SetTimer(float value)
    {
        var val = Mathf.Min(Mathf.Round((value * 18f) * 48), 100);

        candleStem.SetBlendShapeWeight(0, val);
        timeRemaining = 1800 - (18 * candleStem.GetBlendShapeWeight(0));
        FindRatio();
    }

    public IEnumerator Melt()
    {
        FindRatio();
        LightFlame(true);
        float time = 0;
        float startValue = candleStem.GetBlendShapeWeight(0);
        float endValue = 100;
        float startHeight = fire.transform.localPosition.y;
        float endHeight = endPoint.transform.localPosition.y;
        float duration = timeRemaining;

        while (time <= duration)
        {
            candleStem.SetBlendShapeWeight(0, Mathf.Lerp(startValue, endValue, time / duration));
            fire.transform.localPosition = new Vector3(0, Mathf.Lerp(startHeight, endHeight, time / duration), 0f);
            time += Time.deltaTime;
            timeRemaining -= Time.deltaTime;
            DisplayTime(timeRemaining);
            yield return null;
        }
        fire.transform.localPosition = new Vector3(0, endHeight, 0);
        candleStem.SetBlendShapeWeight(0, endValue);
        DisplayTime(0);
        LightFlame(false);
        started = false;
        buttonText.text = "Start";
        yield return null;

    }

}
